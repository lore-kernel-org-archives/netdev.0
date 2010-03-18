From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] r8169: Fix rtl8169_rx_interrupt()
Date: Thu, 18 Mar 2010 15:31:40 +0200
Message-ID: <20100318133140.GA3543@swordfish.minsk.epam.com>
References: <1268699602.2824.14.camel@edumazet-laptop>
 <20100316145914.GB3332@swordfish.minsk.epam.com>
 <1268751933.3094.45.camel@edumazet-laptop>
 <20100316151023.GC3332@swordfish.minsk.epam.com>
 <1268752826.3094.48.camel@edumazet-laptop>
 <20100316182619.GA3451@swordfish>
 <1268765284.2932.17.camel@edumazet-laptop>
 <20100317072539.GA3579@swordfish>
 <1268811437.2932.66.camel@edumazet-laptop>
 <20100317235505.GA6674@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:41674 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab0CRNar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 09:30:47 -0400
Received: by fxm19 with SMTP id 19so2110702fxm.21
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 06:30:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100317235505.GA6674@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,
Patched r8169 (both Eric's and Francois' patches are applied). /*pktgen loc=
alhost2localhost*/

[  498.818640] pktgen 2.72: Packet Generator for packet performance testing.
[  568.999957] ------------[ cut here ]------------
[  568.999969] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0xc1/0x=
125()
[  568.999973] Hardware name: F3JC               =20
[  568.999976] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
[  568.999979] Modules linked in: pktgen snd_hwdep snd_hda_codec_si3054 snd=
_hda_codec_realtek asus_laptop sparse_keymap sdhci_pci sdhci snd_hda_intel =
mmc_core led_class
snd_hda_codec snd_pcm snd_timer psmouse snd soundcore snd_page_alloc sg evd=
ev i2c_i801 rng_core serio_raw r8169 mii uhci_hcd sr_mod ehci_hcd cdrom sd_=
mod usbcore ata_piix
[  569.000029] Pid: 3350, comm: kpktgend_0 Tainted: G        W  2.6.34-rc1-=
dbg-git6-r8169 #48
[  569.000033] Call Trace:
[  569.000041]  [<c102e293>] warn_slowpath_common+0x65/0x7c
[  569.000046]  [<c126c024>] ? dev_watchdog+0xc1/0x125
[  569.000051]  [<c102e2de>] warn_slowpath_fmt+0x24/0x27
[  569.000056]  [<c126c024>] dev_watchdog+0xc1/0x125
[  569.000063]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
[  569.000069]  [<c1036b51>] run_timer_softirq+0x176/0x1eb
[  569.000074]  [<c1036afb>] ? run_timer_softirq+0x120/0x1eb
[  569.000079]  [<c126bf63>] ? dev_watchdog+0x0/0x125
[  569.000084]  [<c1032d39>] __do_softirq+0x8d/0x117
[  569.000089]  [<c1032dee>] do_softirq+0x2b/0x43
[  569.000097]  [<f809510d>] ? pktgen_xmit+0xdb7/0xe8e [pktgen]
[  569.000102]  [<c1032e9c>] _local_bh_enable_ip+0x88/0xb0
[  569.000107]  [<c1032ecc>] local_bh_enable_ip+0x8/0xa
[  569.000114]  [<c12c83a0>] _raw_spin_unlock_bh+0x2f/0x32
[  569.000120]  [<f809510d>] pktgen_xmit+0xdb7/0xe8e [pktgen]
[  569.000129]  [<f91674a9>] ? rtl8169_start_xmit+0x0/0x304 [r8169]
[  569.000136]  [<c1183940>] ? trace_hardirqs_on_thunk+0xc/0x10
[  569.000143]  [<c105012d>] ? print_lock_contention_bug+0x11/0xb2
[  569.000150]  [<f80935ca>] ? spin_lock+0x8/0xa [pktgen]
[  569.000156]  [<f80954a8>] pktgen_thread_worker+0x18d/0x631 [pktgen]
[  569.000163]  [<c103f931>] ? autoremove_wake_function+0x0/0x2f
[  569.000169]  [<c103f931>] ? autoremove_wake_function+0x0/0x2f
[  569.000175]  [<f809531b>] ? pktgen_thread_worker+0x0/0x631 [pktgen]
[  569.000180]  [<c103f60e>] kthread+0x6a/0x6f
[  569.000185]  [<c103f5a4>] ? kthread+0x0/0x6f
[  569.000191]  [<c1002e42>] kernel_thread_helper+0x6/0x1a
[  569.000195] ---[ end trace a22d306b065d4a68 ]---



	Sergey



On (03/18/10 00:55), Francois Romieu wrote:
> > I suspect lot of work is needed on this driver to make it working, but I
> > dont have a machine with said adapter.
>=20
> This one should help too if Sergey owns a (MSI) 8168.
>=20
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index dfc3573..721e7f3 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -4532,21 +4532,39 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
>  	return count;
>  }
> =20
> +static void rtl_napi_cond_schedule(struct rtl8169_private *tp, u16 statu=
s)
> +{
> +	if (status & tp->napi_event) {
> +		void __iomem *ioaddr =3D tp->mmio_addr;
> +
> +		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
> +		mmiowb();
> +		napi_schedule(&tp->napi);
> +	}
> +}
> +
>  static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  {
>  	struct net_device *dev =3D dev_instance;
>  	struct rtl8169_private *tp =3D netdev_priv(dev);
>  	void __iomem *ioaddr =3D tp->mmio_addr;
>  	int handled =3D 0;
> -	int status;
> +	u16 status;
> =20
>  	/* loop handling interrupts until we have no new ones or
>  	 * we hit a invalid/hotplug case.
>  	 */
>  	status =3D RTL_R16(IntrStatus);
>  	while (status && status !=3D 0xffff) {
> +		u16 acked;
> +
>  		handled =3D 1;
> =20
> +		acked =3D (status & RxFIFOOver) ? (status | RxOverflow) : status;
> +		acked &=3D ~tp->napi_event;
> +
> +		RTL_W16(IntrStatus, acked);
> +
>  		/* Handle all of the error cases first. These will reset
>  		 * the chip, so just exit the loop.
>  		 */
> @@ -4557,7 +4575,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void =
*dev_instance)
> =20
>  		/* Work around for rx fifo overflow */
>  		if (unlikely(status & RxFIFOOver) &&
> -		(tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11)) {
> +		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_11)) {
>  			netif_stop_queue(dev);
>  			rtl8169_tx_timeout(dev);
>  			break;
> @@ -4571,30 +4589,9 @@ static irqreturn_t rtl8169_interrupt(int irq, void=
 *dev_instance)
>  		if (status & LinkChg)
>  			rtl8169_check_link_status(dev, tp, ioaddr);
> =20
> -		/* We need to see the lastest version of tp->intr_mask to
> -		 * avoid ignoring an MSI interrupt and having to wait for
> -		 * another event which may never come.
> -		 */
> -		smp_rmb();
> -		if (status & tp->intr_mask & tp->napi_event) {
> -			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
> -			tp->intr_mask =3D ~tp->napi_event;
> -
> -			if (likely(napi_schedule_prep(&tp->napi)))
> -				__napi_schedule(&tp->napi);
> -			else
> -				netif_info(tp, intr, dev,
> -					   "interrupt %04x in poll\n", status);
> -		}
> +		rtl_napi_cond_schedule(tp, status);
> =20
> -		/* We only get a new MSI interrupt when all active irq
> -		 * sources on the chip have been acknowledged. So, ack
> -		 * everything we've seen and check if new sources have become
> -		 * active to avoid blocking all interrupts from the chip.
> -		 */
> -		RTL_W16(IntrStatus,
> -			(status & RxFIFOOver) ? (status | RxOverflow) : status);
> -		status =3D RTL_R16(IntrStatus);
> +		break;
>  	}
> =20
>  	return IRQ_RETVAL(handled);
> @@ -4607,22 +4604,19 @@ static int rtl8169_poll(struct napi_struct *napi,=
 int budget)
>  	void __iomem *ioaddr =3D tp->mmio_addr;
>  	int work_done;
> =20
> +
> +	RTL_W16(IntrStatus, tp->napi_event);
> +
>  	work_done =3D rtl8169_rx_interrupt(dev, tp, ioaddr, (u32) budget);
>  	rtl8169_tx_interrupt(dev, tp, ioaddr);
> =20
>  	if (work_done < budget) {
>  		napi_complete(napi);
> =20
> -		/* We need for force the visibility of tp->intr_mask
> -		 * for other CPUs, as we can loose an MSI interrupt
> -		 * and potentially wait for a retransmit timeout if we don't.
> -		 * The posted write to IntrMask is safe, as it will
> -		 * eventually make it to the chip and we won't loose anything
> -		 * until it does.
> -		 */
> -		tp->intr_mask =3D 0xffff;
> -		smp_wmb();
>  		RTL_W16(IntrMask, tp->intr_event);
> +		mmiowb();
> +
> +		rtl_napi_cond_schedule(tp, RTL_R16(IntrStatus));
>  	}
> =20
>  	return work_done;
>=20

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iJwEAQECAAYFAkuiKzwACgkQfKHnntdSXjQRDAP+PVNUq90m6uIpfoYkrRQhDhRA
fspLaYY4+4TgOkELw62ZHnXstfl1TJiEL7Lq9bpvYC6cmRot9h5RQfCOcuMim+rV
Csm2WNmH3sUIPEyRxdQMlbENAqgPFY+Gh4XdcdtOZYUlOm/dno0mgIOYCfAirq7e
PY+87v7FOsoraf8Pfcw=
=iHBL
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--
