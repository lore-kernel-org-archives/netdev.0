From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: Linux 2.6.35-rc6
Date: Fri, 23 Jul 2010 11:21:42 +1000
Message-ID: <20100723112142.f698394e.sfr@canb.auug.org.au>
References: <AANLkTinJe-oHpgQqnTPQyKUtmKhg2oUJmylkBPALuzGh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__23_Jul_2010_11_21_42_+1000_XmXU=c0L7Xd3+irv"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michal Marek <mmarek@suse.cz>, Greg KH <greg@kroah.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinJe-oHpgQqnTPQyKUtmKhg2oUJmylkBPALuzGh@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__23_Jul_2010_11_21_42_+1000_XmXU=c0L7Xd3+irv
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Thu, 22 Jul 2010 12:26:13 -0700 Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
>
 I actually hope/think that this is going to be the last -rc. Things
> have been pretty quiet, and while this -rc has more commits than -rc5
> had, it's not by a large amount, nor does it look scary to me. So
> there doesn't seem to be any point in dragging out the release any
> more, unless we find something new that calls for it.

I have no idea how important this stuff is, but I still have the
following in linux-next that are (in theory) destined for v2.6.35:

Andrea Shepard (1):
      net: Fix corruption of skb csum field in pskb_expand_head() of net/co=
re/skbuff.c

Andrew Bird (1):
      USB: New PIDs for Qualcomm gobi 2000 (qcserial)

Andy Gospodarek (1):
      ixgbe/igb: catch invalid VF settings

Bob Copeland (1):
      USB: usb-storage: fix initializations of urb fields

Borislav Petkov (1):
      ide-cd: Do not access completed requests in the irq handler

Christof Schmitt (2):
      [SCSI] zfcp: Do not wait for SBALs on stopped queue
      [SCSI] zfcp: Update status read mempool

Colin Leitner (1):
      USB: ftdi_sio: support for Signalyzer tools based on FTDI chips

Corey Minyard (1):
      USB: FTDI: Add support for the RT System VX-7 radio programming cable

David S. Miller (1):
      net: Fix skb_copy_expand() handling of ->csum_start

Dennis Jansen (1):
      USB: option: Add support for AMOI Skypephone S2

Eric Miao (3):
      [ARM] pxa/corgi: fix MMC/SD card detection failure
      [ARM] pxa: fix incorrect order of AC97 reset pin configs
      [ARM] pxa: fix incorrect CONFIG_CPU_PXA27x to CONFIG_PXA27x

Eric W. Biederman (3):
      sysfs: Don't allow the creation of symlinks we can't remove
      sysfs: sysfs_delete_link handle symlinks from untagged to tagged dire=
ctories.
      sysfs: allow creating symlinks from untagged to tagged directories

Felipe Balbi (1):
      USB: musb: tusb6010: fix compile error with n8x0_defconfig

Herbert Xu (1):
      macvtap: Limit packet queue length

John W. Linville (1):
      wireless: use netif_rx_ni in ieee80211_send_layer2_update

Marek Vasut (2):
      [ARM] pxa: cpufreq-pxa2xx: fix DRI recomputation routine
      [ARM] pxa: fix frequency scaling for pcmcia/pxa2xx_base

Michal Marek (1):
      kbuild: Fix make rpm

Micha=C5=82 G=C3=B3rny (1):
      kbuild: Make the setlocalversion script POSIX-compliant

Oliver Neukum (2):
      USB: sisusbvga: Fix for USB 3.0
      USB: add quirk for Broadcom BT dongle

Paul Mortier (1):
      USB: adds Artisman USB dongle to list of quirky devices

Peter Huewe (1):
      serial: fix rs485 for atmel_serial on avr32

Przemo Firszt (1):
      USB: Expose vendor-specific ACM channel on Nokia 5230

Russell King (1):
      Merge branch 'fix' of git://git.kernel.org/.../ycmiao/pxa-linux-2.6

Sarah Sharp (4):
      USB: xHCI: Fix another bug in link TRB activation change.
      USB: Fix USB3.0 Port Speed Downgrade after port reset
      USB: xhci: Set EP0 dequeue ptr after reset of configured device.
      USB: xhci: Set Mult field in endpoint context correctly.

Swen Schillig (1):
      [SCSI] zfcp: Fix check whether unchained ct_els is possible

Vladimir Zapolskiy (1):
      USB: s3c2410_udc: be aware of connected gadget driver

Vladislav Zolotarov (3):
      bnx2x: Protect a SM state change
      bnx2x: Protect statistics ramrod and sequence number
      bnx2x: Advance a module version

Wayne Boyer (1):
      [SCSI] ipr: fix resource path display and formatting

Yann Dirson (1):
      via82cxxx: fix typo for VT6415 PCIE PATA IDE Host Controller support.

august huber (1):
      USB: Add PID for Sierra 250U to drivers/usb/serial/sierra.c

pieterg (1):
      [ARM] pxa/colibri-pxa300: fix AC97 init

wanzongshun (2):
      ARM: 6230/1: fix nuc900 touchscreen clk definition bug
      ARM: 6233/1: Delete a wrong redundant right parenthesis

=C3=96mer Sezgin Ugurlu (1):
      USB: option: add support for 1da5:4518

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__23_Jul_2010_11_21_42_+1000_XmXU=c0L7Xd3+irv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMSO6mAAoJEDMEi1NhKgbsUtwH/RlGqMm5Q7s989unuxiSHuyV
q66WqLQTEs1FOpW38vZrMn0yMomNdEGOjOpWi/cwhma7L2IOcExCwsnOOuQUtm0i
P35XydiiSCUpsLPwsADxecEMMWM19fkD75ABoJ/Z0jlIKj297RmJ+CTSp4l9zx42
IJAyUJkgSAa4KPXfvDG6FNxvIdRHe4ng2sSyMlEgKq/gccP1XWSxdwoon20PkcXY
eoxS+lmlleAMjeEUU1r5WnWA/BodB4/WMIZYubqTvjHSgWmeahAhEf3jJT1A9Pyo
/qDeepgzNuFCP+KfXPtUIzTgh5qKgWmHB+mIZ0Z5WRh51TtqCTFZ8ZTs+AUKxcs=
=9A0a
-----END PGP SIGNATURE-----

--Signature=_Fri__23_Jul_2010_11_21_42_+1000_XmXU=c0L7Xd3+irv--
