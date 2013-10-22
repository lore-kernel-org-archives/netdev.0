From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 0/2] Removal of struct esp_data
Date: Tue, 22 Oct 2013 15:08:22 +0200
Message-ID: <20131022130822.GA26207@secunet.com>
References: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
 <20131018.135536.686066381481925652.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mathias.krause@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37467 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507Ab3JVNIZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 09:08:25 -0400
Content-Disposition: inline
In-Reply-To: <20131018.135536.686066381481925652.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 01:55:36PM -0400, David Miller wrote:
> From: Mathias Krause <mathias.krause@secunet.com>
> Date: Fri, 18 Oct 2013 12:09:03 +0200
> 
> > This series removes one level of indirection when accessing the aead
> > crypto algorithm in ESP transforms by simply removing struct esp_data.
> > This results in smaller code and less memory usage per xfrm state.
> > 
> > Please apply!
> 
> No objections from me, I'll let Steffen pick this up.

I'm a bit hesitating with removing the padlen field. We resisted
several attempts to remove it in the past. It is currenly unused,
but it provides the infrastructure for ESP padding as defined
in RFC 4303. However, RFC 4303 recommends the use of TFC padding
instead to conceal the actual length of the packet. So I'm not
sure what's the actual usecase for ESP padding. I'll reconsider
this next week when I'm back at office.
