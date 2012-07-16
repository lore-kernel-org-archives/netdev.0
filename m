From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH net-next 0/8] etherdevice: Rename random_ether_addr to
 eth_random_addr
Date: Mon, 16 Jul 2012 13:14:38 +0300
Message-ID: <20120716101437.GC22638@arwen.pp.htv.fi>
References: <1341968967.13724.23.camel@joe2Laptop>
 <cover.1342157022.git.joe@perches.com>
Reply-To: balbi-l0cyMroinI0@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KN5l+BnMqAQyZLvT"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	user-mode-linux-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	user-mode-linux-user-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1342157022.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--KN5l+BnMqAQyZLvT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 12, 2012 at 10:33:04PM -0700, Joe Perches wrote:
> net-next commit ad7eee98be ("etherdevice: introduce eth_broadcast_addr")
> added a new style API.  Rename random_ether_addr to eth_random_addr to
> create some API symmetry.
>=20
> Joe Perches (8):
>   etherdevice: Rename random_ether_addr to eth_random_addr

if you're really renaming the function, then this patch alone will break
all of the below users. That should all be a single patch, I'm afraid.

>   ethernet: Use eth_random_addr
>   net: usb: Use eth_random_addr
>   wireless: Use eth_random_addr
>   drivers/net: Use eth_random_addr
>   s390: Use eth_random_addr
>   usb: Use eth_random_addr
>   arch: Use eth_random_addr
>=20
>  arch/blackfin/mach-bf537/boards/stamp.c           |    2 +-
>  arch/c6x/kernel/soc.c                             |    2 +-
>  arch/mips/ar7/platform.c                          |    4 ++--
>  arch/mips/powertv/powertv_setup.c                 |    6 +++---
>  arch/um/drivers/net_kern.c                        |    2 +-
>  drivers/net/ethernet/atheros/atl1c/atl1c_hw.c     |    2 +-
>  drivers/net/ethernet/atheros/atlx/atl1.c          |    2 +-
>  drivers/net/ethernet/atheros/atlx/atl2.c          |    2 +-
>  drivers/net/ethernet/ethoc.c                      |    2 +-
>  drivers/net/ethernet/intel/igb/igb_main.c         |    4 ++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    2 +-
>  drivers/net/ethernet/lantiq_etop.c                |    2 +-
>  drivers/net/ethernet/micrel/ks8851.c              |    2 +-
>  drivers/net/ethernet/micrel/ks8851_mll.c          |    2 +-
>  drivers/net/ethernet/smsc/smsc911x.c              |    2 +-
>  drivers/net/ethernet/ti/cpsw.c                    |    2 +-
>  drivers/net/ethernet/tile/tilegx.c                |    2 +-
>  drivers/net/ethernet/wiznet/w5100.c               |    2 +-
>  drivers/net/ethernet/wiznet/w5300.c               |    2 +-
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
>  drivers/net/tun.c                                 |    2 +-
>  drivers/net/usb/smsc75xx.c                        |    2 +-
>  drivers/net/usb/smsc95xx.c                        |    2 +-
>  drivers/net/usb/usbnet.c                          |    2 +-
>  drivers/net/wimax/i2400m/driver.c                 |    2 +-
>  drivers/net/wireless/adm8211.c                    |    2 +-
>  drivers/net/wireless/p54/eeprom.c                 |    2 +-
>  drivers/net/wireless/rt2x00/rt2400pci.c           |    2 +-
>  drivers/net/wireless/rt2x00/rt2500pci.c           |    2 +-
>  drivers/net/wireless/rt2x00/rt2500usb.c           |    2 +-
>  drivers/net/wireless/rt2x00/rt2800lib.c           |    2 +-
>  drivers/net/wireless/rt2x00/rt61pci.c             |    2 +-
>  drivers/net/wireless/rt2x00/rt73usb.c             |    2 +-
>  drivers/net/wireless/rtl818x/rtl8180/dev.c        |    2 +-
>  drivers/net/wireless/rtl818x/rtl8187/dev.c        |    2 +-
>  drivers/s390/net/qeth_l2_main.c                   |    2 +-
>  drivers/s390/net/qeth_l3_main.c                   |    2 +-
>  drivers/usb/atm/xusbatm.c                         |    4 ++--
>  drivers/usb/gadget/u_ether.c                      |    2 +-
>  include/linux/etherdevice.h                       |   14 ++++++++------
>  40 files changed, 52 insertions(+), 50 deletions(-)
>=20
> --=20
> 1.7.8.111.gad25c.dirty
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--=20
balbi

--KN5l+BnMqAQyZLvT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQA+mNAAoJEIaOsuA1yqRE+ksP/Alli7QgsqKkod+QSJZRmYS6
wJJT+g2ZqoMatSweM3ZCXzeGMBspr3j0TtRqcLxugkaNullhyfqLmyXAW3FQIboF
Aw40vVRTZSjTmecHJB53QVMZ+u+lGKu7u5YAvF+ixof9AXZYPppTEghxHdCtdKou
SpkRsOgw+DwgftlGma27DAiAGTSuV59c74NiOmpCazv2w/TSNF63AkNEfyUH9Cqv
nT7M89z7BJDGoUKKULpN/wKlCl6qWNEtOWShjAmkmhYJBnsIMGEX+w5/4RO8ABOK
p82KlsEl0+Ze5dZGJ1sy64Cs9a50dqIrDcPHtnKwACZqwj9SI6uQSpa9spX5qlqA
64CQzBaudcBcLKzeXlzvOfZmbVbPIXd/wtFXlbYCKGd2Gl+3F211yL7fzd++3RDR
0bIm5vjUjf/c6830awVc6JRUtnLsEzdNnwpNPlm9oCSu5p7TwEGQkhblI7TyYRNV
/Xl5sPiSmIlHfV073zXco8CyuXdHnAUdY7Ujg98KXcXds7AxDd3R4wRa9KykGyVf
Vb4TZ5Rk2bXaFOnfqAT2+aGOGyox/504ud1KVdBvLFc4VLkv4/DN1syiNjDtORu3
Ls+uNzP85uB5c5p49fvM56Mwjzfql47PRKi86OdPebfFCKmLGoVi8k2aHioTvCMO
7qp9s0cYaXJREqb3n+Yb
=EBK7
-----END PGP SIGNATURE-----

--KN5l+BnMqAQyZLvT--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
