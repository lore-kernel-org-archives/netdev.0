From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ah: use crypto_memneq to check the ICV
Date: Thu, 4 May 2017 15:43:57 +0200
Message-ID: <20170504134357.GA25251@bistromath.localdomain>
References: <c53afb48648b2727f6272053f6100c8db3ec6486.1493741168.git.sd@queasysnail.net>
 <20170504104124.GV2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3730 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752216AbdEDNoA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 09:44:00 -0400
Content-Disposition: inline
In-Reply-To: <20170504104124.GV2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-04, 12:41:24 +0200, Steffen Klassert wrote:
> On Wed, May 03, 2017 at 04:57:57PM +0200, Sabrina Dubroca wrote:
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> >  net/ipv4/ah4.c | 5 +++--
> >  net/ipv6/ah6.c | 5 +++--
> >  2 files changed, 6 insertions(+), 4 deletions(-)
> 
> Is this a fix for something? If so, please describe what it fixes.
> If not, it can wait until after the merge window and merged into
> ipsec-next then.

Yeah, not really. I suppose you could see it as a fix for the commit
that introduced crypto_memneq and did some conversions (6bf37e5aa90f
("crypto: crypto_memneq - add equality testing of memory regions w/o
timing leaks")), but that may be a bit of a stretch.

I can repost that for ipsec-next in a couple of weeks.


Thanks,

-- 
Sabrina
