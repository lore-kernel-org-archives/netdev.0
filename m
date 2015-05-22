From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] bridge: allow setting hash_max +
 multicast_router if interface is down
Date: Fri, 22 May 2015 11:17:35 +0800
Message-ID: <20150522031735.GB30043@gondor.apana.org.au>
References: <1432256161-4425-1-git-send-email-linus.luessing@c0d3.blue>
 <CAHA+R7M+F88KsAJy-fGkSjUXxgBNifdML0E3r8jrQqXafZMUpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus =?iso-8859-1?Q?L=FCssing?= <linus.luessing@c0d3.blue>,
	netdev <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37511 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbbEVDRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 23:17:47 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7M+F88KsAJy-fGkSjUXxgBNifdML0E3r8jrQqXafZMUpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2015 at 08:11:32PM -0700, Cong Wang wrote:
>
> For me it looks like we do use p->rlist in BH context, but I could easily
> miss something here.

Because the caller disables BH for us.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
