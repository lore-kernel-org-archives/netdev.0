From: Phillip Susi <psusi@ubuntu.com>
Subject: Re: bind() should not return -EADDRINUSE
Date: Thu, 11 Dec 2014 15:17:12 -0500
Message-ID: <5489FBC8.4070706@ubuntu.com>
References: <5489EE2F.6030502@ubuntu.com>	<20141211.142355.854082841833367081.davem@davemloft.net>	<5489F598.9020708@ubuntu.com> <20141211.151302.686998496408277043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34053 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbaLKURQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:17:16 -0500
Received: by mail-qc0-f180.google.com with SMTP id i8so4385232qcq.25
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 12:17:15 -0800 (PST)
In-Reply-To: <20141211.151302.686998496408277043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/11/2014 3:13 PM, David Miller wrote:
> 
> But you don't know ahead of time what the processes are going to 
> do, that's the problem.
> 
> You cannot leave the port available and pretend to another process 
> that he will be able to use it.
> 
> Port allocation failures must be signalled at bind() time.

Says who?  The man pages for both listen() and connect() say they can
return EADDRINUSE.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)

iQEcBAEBAgAGBQJUifvIAAoJENRVrw2cjl5R+r8H/jb84r9KUgMQcfFAPB4aYQKt
ou188Bpv6aa1AB1yt99il8bulvXMO5m0NuLG8NcYIDnt0zo1xaVrbxelNHIkx0XQ
Gj67Ozc+yMOQ6izHUPMNgB9lI3q/GBhI6dt5/5NnIeAx4VzCQIhT1nKT6LRo4J6z
k6R7vyXrm9M7X0A3hh7Dpapv/JWuzZfZYOZP+JQP/BSLorEX0+pZHoqOl0Cy+bwo
rp/oaAAaQe+cX95dplXLVmXoh6JxjBTkXqWEEHTnNNbz3LsY+e7aokz3Pl9kQw3M
hn1q9PSC+JMhxCI3AOgukIwlK3ps7y78PiQHxds/K/ZNVzaaeJAY+FryppUijPk=
=/oDW
-----END PGP SIGNATURE-----
