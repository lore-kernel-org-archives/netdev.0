From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: RTL8192CU on ARM not working
Date: Fri, 28 Jun 2013 15:40:08 +0200
Message-ID: <20130628134008.GI4319@lukather>
References: <20130627081225.GJ5803@lukather>
 <CACQ1gAiHVxjnt2qx5Y9dEMAbZs5Ki_wEHLhOjDRcPc+xjBU76A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q59ABw34pTSIagmi"
Cc: Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Brian Lilly <brian-ZKiFAVwZFM2FeswfMrDH8w@public.gmane.org>,
	Brent-Crosby <brent-ZKiFAVwZFM2FeswfMrDH8w@public.gmane.org>, Jim Wall <jimwall@q.com>,
	Thomas Petazzoni <thomas-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Richard Genoud <richard.genoud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CACQ1gAiHVxjnt2qx5Y9dEMAbZs5Ki_wEHLhOjDRcPc+xjBU76A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Q59ABw34pTSIagmi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Richard, Larry,

On Thu, Jun 27, 2013 at 02:13:31PM +0200, Richard Genoud wrote:
> 2013/6/27 Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>:
> > Hi everyone,
> >
> > I'm currently trying to use a RTL8192CU on an ARM (Freescale imx28,
> > armv5) platform, using 3.10-rc3.
> >
> > Trouble is, while the chip is correctly detected and you can use iw on =
it
> > without any problem it seems, once you start an association to an access
> > point, the association goes on, seems to associate, displaying a WARN()
> > message [1] and then, after what looks like a random amount of time (co=
uld
> > be right away, could be after a few minutes), deassociate [2].
> >
> > During the time where it's associated, we never seem to transmit any
> > packets, while iw reports packets being sent, I guess we can assume that
> > they are actually never transmitted as well [3].
> >
> > What seems odd to me as well is that the signal power reported for the =
access
> > point is excessively high when using iw scan (10 dbm), and once connect=
ed, the
> > signal strength is -64dbm, which makes quite a huge difference.
> >
> > Do you have any suggestions on how to solve this issue?
> >
> > Thanks,
> > Maxime
> >
> >
> > [1]:
> > # iw wlan0 connect FreeWifi 2447
> > # [  485.010858] wlan0: authenticate with f4:ca:e5:c9:f5:91
> > [  485.065514] wlan0: send auth to f4:ca:e5:c9:f5:91 (try 1/3)
> > [  485.075963] wlan0: authenticated
> > [  485.088915] wlan0: associate with f4:ca:e5:c9:f5:91 (try 1/3)
> > [  485.117137] wlan0: RX AssocResp from f4:ca:e5:c9:f5:91 (capab=3D0x40=
1 status=3D0 aid=3D1)
> > [  485.130607] wlan0: associated
> > [  486.917555] ------------[ cut here ]------------
> > [  486.922277] WARNING: at kernel/workqueue.c:1365 __queue_work+0x1f0/0=
x2f4()
> > [  486.929175] Modules linked in:
> > [  486.932284] CPU: 0 PID: 615 Comm: kworker/0:2 Not tainted 3.10.0-rc3=
 #2
> > [  486.938958] Workqueue: rtl92c_usb rtl_watchdog_wq_callback
> > [  486.944548] [<c00147dc>] (unwind_backtrace+0x0/0xf0) from [<c00120a0=
>] (show_stack+0x10/0x14)
> > [  486.953132] [<c00120a0>] (show_stack+0x10/0x14) from [<c001d2ec>] (w=
arn_slowpath_common+0x4c/0x68)
> > [  486.962140] [<c001d2ec>] (warn_slowpath_common+0x4c/0x68) from [<c00=
1d324>] (warn_slowpath_null+0x1c/0x24)
> > [  486.971844] [<c001d324>] (warn_slowpath_null+0x1c/0x24) from [<c0037=
69c>] (__queue_work+0x1f0/0x2f4)
> > [  486.981025] [<c003769c>] (__queue_work+0x1f0/0x2f4) from [<c0037830>=
] (queue_work_on+0x80/0x88)
> > [  486.989777] [<c0037830>] (queue_work_on+0x80/0x88) from [<c0267ca4>]=
 (rtl_watchdog_wq_callback+0x5dc/0x8bc)
> > [  486.999572] [<c0267ca4>] (rtl_watchdog_wq_callback+0x5dc/0x8bc) from=
 [<c0038cbc>] (process_one_work+0x1c0/0x4c8)
> > [  487.009795] [<c0038cbc>] (process_one_work+0x1c0/0x4c8) from [<c0039=
684>] (worker_thread+0x140/0x3ac)
> > [  487.019065] [<c0039684>] (worker_thread+0x140/0x3ac) from [<c003f914=
>] (kthread+0xa4/0xb0)
> > [  487.027381] [<c003f914>] (kthread+0xa4/0xb0) from [<c000f0c0>] (ret_=
=66rom_fork+0x14/0x34)
> > [  487.035498] ---[ end trace 93341a0c249e647e ]---
> >
> >
> > [2]:
> >
> > # [  786.086127] wlan0: deauthenticated from f4:ca:e5:c9:f5:91 (Reason:=
 2)
> > [  786.126368] cfg80211: Calling CRDA to update world regulatory domain
> >
> >
> > [3]:
> > # iw wlan0 station dump
> > Station f4:ca:e5:c9:f5:91 (on wlan0)
> >         inactive time:  55430 ms
> >         rx bytes:       77826
> >         rx packets:     1026
> >         tx packets:     2
> >         tx retries:     0
> >         tx failed:      0
> >         signal:         -64 dBm
> >         signal avg:     -63 dBm
> >         tx bitrate:     1.0 MBit/s
> >         authorized:     yes
> >         authenticated:  yes
> >         preamble:       long
> >         WMM/WME:        yes
> >         MFP:            no
> >         TDLS peer:      no
>=20
> Hi Maxime,
>=20
> You should have a look at https://lkml.org/lkml/2013/6/11/300
> (in short, use 3.10-rc7)
>=20
> The warning is still there, but I managed use this device on ARM
> (sam9g35) as a client.

Indeed, the client mode works way better with 3.10-rc7.

Thanks to you two!
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--Q59ABw34pTSIagmi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRzZI4AAoJEBx+YmzsjxAga9YP/jHrL2dd0fMJos3IUqO53bda
fvRh93rCqaEVirEeCF8RKW6ktYeo4tEZSZq9BCZwI4XTuv/Z5qvXDQ7jwFeBCn+b
/Ai8l0xO72076B68g6xve4ncjGD781rZzBr3PfnXoyi0gPO6nC+54KjuG1kSs7EN
A9XAH/tnqp0Srt3FqBcQUeKYUmVRKdup0/Ekb4XzDL+ipvAilzAWfKa47mroqDGC
vAYa2HMWmFDo1OFfxqOmKQbX6PIYw5RjrXHhV19IexFUanYfy3SRXYzzELJh3iyR
rz5/beHiABiAcUqVuGnxkoim9mgeGqVDAEiGVbgF8S0+I8+DKRwhdxvsxD1gQA8M
lf2yqv8iyfv/+4aUdO8zz3Pynbf6oHZLaDvuVSye2VPby1lsIsaM0f5mAlpu1aDw
BGhhB62fY8MYcrcRVjkQJ56IaSSThntUa5JS3OV6WXaKpObEreHNNx50CW2fyGtq
2JXfbOBK8My8cRVHvR6p6lcLVmpw6C6Mcj9t+USBUALfL7dZkKKzrxe4tMgXJo07
yTHfASo5yhF1oeBfDv7/4fVv3MVdg65ST8mYEJhsMPrR1oTNsw+nU9c3OkUA3z7H
16vK5deLCBp8RTTYcd+NlnF3uOFk3EBVFCNp1vKx7c8SfOsUX9Ez9H7AeLW9lBZ6
6pzdeLvBzeNBuE5QX2yO
=r5Bg
-----END PGP SIGNATURE-----

--Q59ABw34pTSIagmi--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
