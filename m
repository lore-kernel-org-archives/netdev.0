From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] rhashtable: don't attempt to grow when at max_size
Date: Thu, 23 Apr 2015 18:09:36 +0200
Message-ID: <1429805376.1859.5.camel@sipsolutions.net>
References: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
	 <20150423.115919.1353583175267783165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:35321 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965896AbbDWQJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 12:09:40 -0400
In-Reply-To: <20150423.115919.1353583175267783165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-04-23 at 11:59 -0400, David Miller wrote:

> > This fixes the "lost insertion" issue and consequently allows my
> > code to display its error (and verify my fix for it.)

> It looks fine to me, but I'll let Herbert and Thomas review this.

Oh, sorry, didn't know Herbert was also involved with this.

Anyway, that's a good idea. I really went for "this looks obvious" and
patched it, and it started working for me thereafter. I don't know
anything about side effects here.

johannes
