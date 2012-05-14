From: valdis.kletnieks@vt.edu
Subject: Re: [PATCH 1/2] Bluetooth: notify userspace of security level change
Date: Mon, 14 May 2012 12:22:16 -0400
Message-ID: <15456.1337012536@turing-police.cc.vt.edu>
References: <1336849910-29064-2-git-send-email-gustavo@padovan.org>
            <1336890007-10646-1-git-send-email-gustavo@padovan.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1337012536_2289P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gustavo Padovan <gustavo@padovan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:54736 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757191Ab2ENQWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 12:22:30 -0400
Received: from dagger.cc.vt.edu (dagger.cc.vt.edu [198.82.163.114])
	by lennier.cc.vt.edu (8.13.8/8.13.8) with ESMTP id q4EGMU3a013353
	for <netdev@vger.kernel.org>; Mon, 14 May 2012 12:22:30 -0400
Received: by ggnf1 with SMTP id f1so2894470ggn.25
        for <netdev@vger.kernel.org>; Mon, 14 May 2012 09:22:19 -0700 (PDT)
In-Reply-To: Your message of "Sun, 13 May 2012 03:20:07 -0300."
             <1336890007-10646-1-git-send-email-gustavo@padovan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1337012536_2289P
Content-Type: text/plain; charset=us-ascii

On Sun, 13 May 2012 03:20:07 -0300, Gustavo Padovan said:

> It enables the userspace a security level change when the socket is
> already connected and create a way to notify the socket the result of the
> request. At the moment of the request the socket is made non writable, if
> the request fails the connections closes, otherwise the socket is made
> writable again, POLL_OUT is emmited.

What happens to in-flight data already written but not yet consumed?  I'm
smelling a possible race condition with data sent under the old level but
read under the new level....

--==_Exmh_1337012536_2289P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBT7ExOAdmEQWDXROgAQIEXxAAvEkGmcWB3xSQnwxaG6YPP3bMreXbmyKv
sc3L0TJ49yyyfVXND63wLV+jpnhdmRfTg/YkPzUSdv5QM26bf7eN8xPHl7cNYsTW
/UzJmC3x+rb03ixjPWMAQFUwJ5LmB/Vm6VwkonMmgQRRgc0ICSrl+hQuBxO9vrbg
oldwJPTR/ILslBJzvfK6Mwv+hmXcDVa8X2UAFpN/dSGzwfV1vIcseuQSI/JXDKvN
b+UOX5zumHJFPIOhRqsS3FAYHsUbf8BWMFXuqfzQUbv4c+dd3V+OFKDQx11cHS5O
d3vNWvCoxKgZt3shD5j2wx8RCcz4qVlmwdvlnz+Vksmsn6HFyNdrxv0vSAwxlsPV
yPnzptcnotIWFjKD40IeKQb+SRmILLqlhosXTyYIkFWnYl7N3iZHfeh1ohMsYNtd
SMov/cOt91e0BB9iUw3FFRUEAkTnrkXdv+TehT5G7tEwtcTOWr3BPzaJIKlqs12Z
Our3yILTGFg1OvItS2zJ4j5XiXGxpTYCvRWSt+77nLAGg282PbKaZGniCYbQiZpv
MO5Makfc0EE0pUMaPTL8A753w+8P/mYGc0vJb/qCQ49HfaxteTjrle6SWapp0ZCU
8uBARtq2nPdWj/nu6KKf2BAmq1J/Ay1i8mjDWsauDwXE7yYahLvYQkDXm3JWBB9M
H685+ryqnJg=
=ofMS
-----END PGP SIGNATURE-----

--==_Exmh_1337012536_2289P--
