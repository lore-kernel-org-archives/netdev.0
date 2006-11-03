From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: New stuff in wireless-dev, wireless developers please pull...
Date: Fri, 3 Nov 2006 01:42:03 -0500
Message-ID: <200611030142.09303.flamingice@sourmilk.net>
References: <20061103043024.GF2989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3344189.VuyZcQvr8K";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:14641 "EHLO
	annwn13.rutgers.edu") by vger.kernel.org with ESMTP
	id S1753158AbWKCGmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 01:42:17 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061103043024.GF2989@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3344189.VuyZcQvr8K
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 02 November 2006 23:30, John W. Linville wrote:
> One big addition is the cfg80211/nl80211 stuff from Johannes.  I'm not
> quite confident that the Kconfig stuff is right, but the code is there.
It doesn't seem to compile on my system:

net/built-in.o: In function `iw_send_thrspy_event':
wext-old.c:(.text+0x67672): undefined reference to `wireless_send_event'
net/built-in.o: In function `ioctl_standard_call':
wext-old.c:(.text+0x677bf): undefined reference to `standard_ioctl_num'
wext-old.c:(.text+0x677ea): undefined reference to `standard_ioctl'
wext-old.c:(.text+0x677f1): undefined reference to `standard_ioctl'
wext-old.c:(.text+0x679b9): undefined reference to `wireless_send_event'
wext-old.c:(.text+0x679f0): undefined reference to `wireless_send_event'
wext-old.c:(.text+0x67abf): undefined reference to `wireless_send_event'
net/built-in.o: In function `iw_handler_get_iwstats':
wext-old.c:(.text+0x67f67): undefined reference to `get_wireless_stats'
net/built-in.o: In function `net_dev_init':
dev.c:(.init.text+0x28e): undefined reference to `wireless_proc_init'
net/built-in.o:(__ksymtab+0x1248): undefined reference to=20
`wireless_send_event'
make: *** [.tmp_vmlinux1] Error 1

This is with cfg80211 turned off.=20

Thanks,
=2DMichael Wu

--nextPart3344189.VuyZcQvr8K
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFSuTBT3Oqt9AH4aERAi/hAJ9SdQ/7z7OEKtH9ZPC2vw4aGX7UnwCaApx/
37IrMN5vYJCGqBQno0Sb/B8=
=ooce
-----END PGP SIGNATURE-----

--nextPart3344189.VuyZcQvr8K--
