From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Tigon3 crash when used with any torrent app
Date: Wed, 11 Oct 2006 14:39:32 +1000
Message-ID: <E1GXVsS-0001cd-00@gondolin.me.apana.org.au>
References: <1551EAE59135BE47B544934E30FC4FC093FBFF@NT-IRVA-0751.brcm.ad.broadcom.com>
Cc: sas@noend.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55820 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030787AbWJKEkT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 00:40:19 -0400
To: mchan@broadcom.com (Michael Chan)
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FBFF@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan <mchan@broadcom.com> wrote:
> Sebastian Alfredo Salvino wrote:
> 
>> However when I am booted up into 2.6.18 and try to connect to 
>> any p2p network 
>> via BitTorrent, KTorrent, etc., it just hang. 
> 
> Did the same setup work in 2.6.17?  If yes, can you bisect
> the tg3 patches between 2.6.17 and 2.6.18?

Does ping still work? If so you might want to take a tcpdump
as this indicates a TCP-level problem (window-scaling being
the most likely cause).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
