From: Phillip Susi <psusi@ubuntu.com>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 15:23:45 -0500
Message-ID: <5489FD51.3030609@ubuntu.com>
References: <5489F598.9020708@ubuntu.com>	<20141211.151302.686998496408277043.davem@davemloft.net>	<5489FBC8.4070706@ubuntu.com> <20141211.151804.2024237965934539073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:47825 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758767AbaLKUXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:23:52 -0500
Received: by mail-qa0-f49.google.com with SMTP id s7so4135713qap.36
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:23:52 -0800 (PST)
In-Reply-To: <20141211.151804.2024237965934539073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/11/2014 3:18 PM, David Miller wrote:
> From: Phillip Susi <psusi@ubuntu.com> Date: Thu, 11 Dec 2014
> 15:17:12 -0500
> 
>> Says who?
> 
> Says multiple decades of precendence.

"It has always been broken, so it should stay broken" isn't a very
compelling argument.

Would it cause programs to break if they get the error at listen()
time instead of bind() time ( as the man page indicates it can )?  I
think not.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQEcBAEBAgAGBQJUif1OAAoJENRVrw2cjl5RW8YH/0Rmg3JXGHJZr/z9H56F0Tfo
m9mGM5THOUIXFaCugiqea/6Y9j1qvZC4OJdoB8Ve/bDTpTa2bs3SHd81eEntVpGI
hXoeMw5RQxUuiBpKLmkWp+ma8Cl01qIADkTdRG2F/pPa8ee9xd4Lx0UGV6skUnVP
6HVuqeNxPS1xESQMpUAgO8KLGkvzB1/y8+7iBuc0fINZuox4KX8CVwzQB7d9I+G1
gf+yMaFtsDnNeGrXLKdSj7q+/yV61AgigSt3IeFIdUz+trbZa2W/6vUkBqVPB9bo
QEClO9JROTIkkl2ErUyd+bnrKTNJR0/tkOUmqf8JjQhjSnozD/u0JdoQRMvjQtk=
=PUUw
-----END PGP SIGNATURE-----
