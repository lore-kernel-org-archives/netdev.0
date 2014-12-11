From: Phillip Susi <psusi@ubuntu.com>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 16:34:14 -0500
Message-ID: <548A0DD6.3020702@ubuntu.com>
References: <5489FBC8.4070706@ubuntu.com>	<20141211.151804.2024237965934539073.davem@davemloft.net>	<5489FD51.3030609@ubuntu.com> <20141211.152518.1988079810884987306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:54713 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965678AbaLKVeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 16:34:19 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so4562021qcx.40
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 13:34:19 -0800 (PST)
In-Reply-To: <20141211.152518.1988079810884987306.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/11/2014 3:25 PM, David Miller wrote:
> You will definitely break programs that look for a locally
> available port by iterating over bind() calls.
> 
> Sorry, this is not changing, no matter how strongly you may wish
> it to.

According to this very nice post, it is how BSD does it, at least when
you specify SO_REUSEADDR:

http://stackoverflow.com/a/14388707/884259

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQEcBAEBAgAGBQJUig3WAAoJENRVrw2cjl5ROzkIAJMyXGo6OA34TFz2pXlWUlLR
+aA6UGC99oM6QV0y/sFnRGSlp4tIMTUQuFS7JzVCKHNRbm9dixtTdXLKpinBuUw/
Y1ZIO1+DyV457T05Q7w9oBxxxNqdLCRlLnVxolTiLN5IJ0mkEN+CaVJVuSl/Tx+S
YtEmCyDShpE+xwQndOUQtt0WU2ZonrKGhYH1aA6YRSyxfX1N4vTuSKqCUvsSubfm
r3tt22A6FaRey0pHzxSqzNcyvHe63THC8b556ggOcQM+yFf3C92FNyvyUWxETtdb
2VrXgGEYnXtcLXtSwYLOnQAXwW9yRg64BkinMDybVt7b6aNDG5653+Vi/NniysU=
=NxIM
-----END PGP SIGNATURE-----
