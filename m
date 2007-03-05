From: Rob Sims <rob@robsims.com>
Subject: Re: [RFT] sky2 auto negotiation PHY errata
Date: Mon, 5 Mar 2007 07:23:54 -0700
Message-ID: <20070305142354.GA31178@robsims.com>
References: <20070202112846.31acaa03@freekitty> <20070220184212.GC30164@robsims.com> <20070220110053.74f26b4d@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dilbert.robsims.com ([209.120.158.98]:60452 "EHLO
	mail.robsims.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933482AbXCEOX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 09:23:59 -0500
Content-Disposition: inline
In-Reply-To: <20070220110053.74f26b4d@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 20, 2007 at 11:00:53AM -0800, Stephen Hemminger wrote:
> You need the flow control fix and the tx_timeout fix posted for 2.6.20 (s=
table)
> and current git tree.=20

sky2 1.13 has been far better than 1.10; there have been no system hangs
or permanent sky2 failures.  However, the following two incidents were
in syslog:

Feb 27 07:08:21 btd kernel: Linux version 2.6.20.sky2.1.13-btd3 (root@btd.r=
obsims.com) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 =
SMP PREEMPT Tue Feb 27 00:07:34 MST 2007
Feb 27 07:08:21 btd kernel: sky2 0000:04:00.0: v1.13 addr 0xfa9fc000 irq 17=
 Yukon-EC (0xb6) rev 2
Feb 27 07:08:21 btd kernel: sky2 eth0: addr 00:1a:92:23:52:4d
Feb 27 07:08:21 btd kernel: sky2 0000:03:00.0: v1.13 addr 0xfa8fc000 irq 16=
 Yukon-EC (0xb6) rev 2
Feb 27 07:08:21 btd kernel: sky2 eth1: addr 00:1a:92:23:4b:a6
Feb 27 07:08:21 btd kernel: sky2 eth0: enabling interface
Feb 27 07:08:21 btd kernel: sky2 eth0: ram buffer 48K
Feb 27 07:08:21 btd kernel: sky2 eth0: Link is up at 1000 Mbps, full duplex=
, flow control both
Feb 27 19:48:34 btd kernel: sky2 0000:04:00.0: v1.13 addr 0xfa9fc000 irq 17=
 Yukon-EC (0xb6) rev 2
Feb 27 19:48:34 btd kernel: sky2 eth0: addr 00:1a:92:23:52:4d
Feb 27 19:48:34 btd kernel: sky2 0000:03:00.0: v1.13 addr 0xfa8fc000 irq 16=
 Yukon-EC (0xb6) rev 2
Feb 27 19:48:34 btd kernel: sky2 eth1: addr 00:1a:92:23:4b:a6
Feb 27 19:48:34 btd kernel: sky2 eth0: enabling interface
Feb 27 19:48:34 btd kernel: sky2 eth0: ram buffer 48K
Feb 27 19:48:34 btd kernel: sky2 eth0: Link is up at 1000 Mbps, full duplex=
, flow control both

Feb 28 19:06:57 btd kernel: NETDEV WATCHDOG: eth0: transmit timed out
Feb 28 19:06:57 btd kernel: sky2 eth0: tx timeout
Feb 28 19:06:57 btd kernel: sky2 eth0: transmit ring 133 ..  110 report=3D1=
33 done=3D133
Feb 28 19:06:57 btd kernel: sky2 eth0: disabling interface
Feb 28 19:06:57 btd kernel: sky2 eth0: enabling interface
Feb 28 19:06:57 btd kernel: sky2 eth0: ram buffer 48K
Feb 28 19:07:00 btd kernel: sky2 eth0: Link is up at 1000 Mbps, full duplex=
, flow control both

Mar  4 13:58:31 btd kernel: NETDEV WATCHDOG: eth0: transmit timed out
Mar  4 13:58:31 btd kernel: sky2 eth0: tx timeout
Mar  4 13:58:31 btd kernel: sky2 eth0: transmit ring 353 .. 330 report=3D35=
3 done=3D353
Mar  4 13:58:31 btd kernel: sky2 eth0: disabling interface
Mar  4 13:58:31 btd kernel: sky2 eth0: enabling interface
Mar  4 13:58:31 btd kernel: sky2 eth0: ram buffer 48K
Mar  4 13:58:34 btd kernel: sky2 eth0: Link is up at 1000 Mbps, full duplex=
, flow control both

I only noticed the second of the two.
--=20
Rob

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFF7Cf6nvKppSZW8osRAmtfAJ9yv3fRhmarhvv6uSfmkdZ1pvCvLwCcCEAS
1kxFShFyd3OM1dPhieCBpuM=
=RYBR
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
