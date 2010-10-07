From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Linux 2.6.36-rc7
Date: Thu, 7 Oct 2010 11:49:38 +1100
Message-ID: <20101007114938.ad3d2c76.sfr@canb.auug.org.au>
References: <AANLkTi=LsBNU+O2hqZUcM2nYM_ze6qPq3thwSZBMtY_v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__7_Oct_2010_11_49_38_+1100_Hd=TzG.Jc9LIeuGC"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michal Marek <mmarek@suse.cz>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:59744 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759115Ab0JGAts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 20:49:48 -0400
In-Reply-To: <AANLkTi=LsBNU+O2hqZUcM2nYM_ze6qPq3thwSZBMtY_v@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__7_Oct_2010_11_49_38_+1100_Hd=TzG.Jc9LIeuGC
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Wed, 6 Oct 2010 14:45:13 -0700 Linus Torvalds <torvalds@linux-foundation=
.org> wrote:
>
> This should be the last -rc, I'm not seeing any reason to keep
> delaying a real release. There was still more changes to
> drivers/gpu/drm than I really would have hoped for, but they all look
> harmless and good. Famous last words.

I have no idea how critical any of this stuff is, but linux-next contain
the following in it's "current" trees i.e. stuff that is supposed to go
into 2.6.36.  These are from the arm-current, scsi-rc-fixes, net-current,
wireless-current, kbuild-current, input-current and ide-curent trees
(contacts cc'd).

Arnaud Lacombe (1):
      kconfig: delay symbol direct dependency initialization
[This one produces a lot of new warnings, but also fixes a bug ...]

Ben Hutchings (2):
      Revert "ipv4: Make INET_LRO a bool instead of tristate."
      netdev: Depend on INET before selecting INET_LRO

Dan Carpenter (1):
      cls_u32: signedness bug

Dan Rosenberg (2):
      sctp: prevent reading out-of-bounds memory
      sctp: Fix out-of-bounds reading in sctp_asoc_get_hmac()

David Stevens (1):
      ipv4: correct IGMP behavior on v3 query during v2-compatibility mode

Dmitry Torokhov (1):
      Input: wacom - fix runtime PM related deadlock

Eric Dumazet (1):
      caif: fix two caif_connect() bugs

Felix Fietkau (1):
      ath9k_hw: fix regression in ANI listen time calculation

Henrik Rydberg (1):
      Input: uinput - setup MT usage during device creation

Jeff Kirsher (4):
      ixgbevf.txt: Update ixgbevf documentation
      e1000.txt: Update e1000 documentation
      e1000e.txt: Add e1000e documentation
      MAINTAINERS: update Intel LAN Ethernet info

Johannes Berg (1):
      mac80211: delete AddBA response timer

Kenneth Waters (1):
      Input: joydev - fix JSIOCSAXMAP ioctl

Maciej =C5=BBenczykowski (1):
      net: Fix IPv6 PMTU disc. w/ asymmetric routes

Martin K. Petersen (1):
      [SCSI] Fix VPD inquiry page wrapper

Nagendra Tomar (1):
      net: Fix the condition passed to sk_wait_event()

Neil Horman (1):
      bonding: fix WARN_ON when writing to bond_master sysfs file

Santosh Shilimkar (1):
      ARM: 6419/1: mmu: Fix MT_MEMORY and MT_MEMORY_NONCACHED pte flags

Sergei Shtylyov (2):
      hpt366: add debounce delay to cable_detect() method
      hpt366: fix clock turnaround

Stanislaw Gruszka (1):
      skge: add quirk to limit DMA

Will Deacon (2):
      ARM: 6416/1: errata: faulty hazard checking in the Store Buffer may l=
ead to data corruption
      ARM: 6412/1: kprobes-decode: add support for MOVW instruction

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__7_Oct_2010_11_49_38_+1100_Hd=TzG.Jc9LIeuGC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMrRkiAAoJEDMEi1NhKgbsUekH/3omT671i4yr9EmGcnElaNSt
V9w4JIFMyoZ1agEbW7h65qR1YG82wM1h07nGoLugJSx4loEFhnu2l+WvW84FRi9n
USDUoc8vascnvjt8BLdz95TFAdGeoJTqKKd7F8ARdMgQk/ExMw3AB7k1+mYr+D+T
sL7XG+8MHDoEEKzzfV/ePDl9/RGVyhAGNN3AquXfl368wMnx0dF7KCZrk47FTwZv
JK8m24ltxrnMNgo4Aqtjv1h4pquXBnmXbDU3h2/fk+j66YcgeudCMrNR445AflDN
eT20zCn1TQGcJkO+2UsbVyXtbtfVuMVOO0XPTza8uFgd/u536sNGq2Of6IXJ5hg=
=Fs80
-----END PGP SIGNATURE-----

--Signature=_Thu__7_Oct_2010_11_49_38_+1100_Hd=TzG.Jc9LIeuGC--
