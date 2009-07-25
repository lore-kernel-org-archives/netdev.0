From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Jumbo frame question...
Date: Sat, 25 Jul 2009 11:28:37 +0800
Message-ID: <20090725032837.GA30871@gondor.apana.org.au>
References: <200907241141.55097.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37690 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752484AbZGYD2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 23:28:39 -0400
Content-Disposition: inline
In-Reply-To: <200907241141.55097.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robin Getz <rgetz@blackfin.uclinux.org> wrote:
> Should a gigabit card, configured as 100, be sending jumbo UDP frames?
> 
> My understanding, is no - this is a spec violation..
> 
> 
> Settings for eth0:
>        Supported ports: [ MII ]
>        Supported link modes:   10baseT/Half 10baseT/Full
>                                100baseT/Half 100baseT/Full
>                                1000baseT/Half 1000baseT/Full
>        Supports auto-negotiation: Yes
>        Advertised link modes:  10baseT/Half 10baseT/Full
>                                100baseT/Half 100baseT/Full
>                                1000baseT/Half 1000baseT/Full
>        Advertised auto-negotiation: Yes
>        Speed: 100Mb/s
>        Duplex: Half
>        Port: Twisted Pair
>        PHYAD: 1
>        Transceiver: internal
>        Auto-negotiation: on
>        Supports Wake-on: g
>        Wake-on: d
>        Current message level: 0x000000ff (255)
>        Link detected: no
> 
> happly sends UDP packets over 1500 bytes in length.
> 
> Tested with TFTP, and 2.6.27 (as the tftp server).

What's the kernel that you're running on the machine doing the
sending, 2.6.27? If it's the latest kernel then it may be related
to the UFO work that went in recently.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
