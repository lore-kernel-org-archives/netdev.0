From: Thomas Meyer <thomas@m3y3r.de>
Subject: Re: NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
Date: Tue, 21 Feb 2012 18:56:55 +0100
Message-ID: <1329847015.5133.4.camel@localhost.localdomain>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	jcliburn@gmail.com, chris.snook@gmail.com,
	netdev <netdev@vger.kernel.org>, Josh Boyer <jwboyer@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:45756 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532Ab2BUR5E convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:57:04 -0500
In-Reply-To: <1329366846.5646.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 16.02.2012, 05:34 +0100 schrieb Eric Dumazet:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 08:36 +0100, Eric Dumazet a =C3=A9=
crit :
> > Le lundi 13 f=C3=A9vrier 2012 =C3=A0 16:00 -0500, Josh Boyer a =C3=A9=
crit :
> > > On Sun, Feb 12, 2012 at 11:16 AM, Thomas Meyer <thomas@m3y3r.de> =
wrote:
> > > > abrt_version:   2.0.7
> > > > cmdline:        BOOT_IMAGE=3D/vmlinuz-3.2.3 root=3D/dev/sda2 ro=
otfstype=3Dext4 rootflags=3Ddata=3Dwriteback ro quiet rhgb
> > > > kernel:         3.2.3
> > > > reason:         WARNING: at net/sched/sch_generic.c:255 dev_wat=
chdog+0x1e7/0x1f0()
> > > > time:           Sa 04 Feb 2012 15:31:22 CET
> > > >
> > > > backtrace:
> > > > :WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1e7/0x1=
f0()
> > > > :Hardware name: Aspire 1810T
> > > > :NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed out
> > > > :Modules linked in: vfat fat fuse bluetooth nf_conntrack_ipv6 n=
f_defrag_ipv6 ip6t_REJECT ip6table_filter ip6_tables snd_hda_codec_hdmi=
 snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep uvcvideo s=
nd_seq arc4 videodev usb_storage snd_seq_device v4l2_compat_ioctl32 snd=
_pcm snd_timer acer_wmi iwlwifi snd mac80211 sparse_keymap cfg80211 rfk=
ill soundcore snd_page_alloc joydev wmi acerhdf pcspkr virtio_net virti=
o atl1c virtio_ring kvm_intel kvm uinput ipv6 [last unloaded: scsi_wait=
_scan]
> > > > :Pid: 0, comm: swapper Not tainted 3.2.3 #5
> > > > :Call Trace:
> > > > : <IRQ>  [<ffffffff810322ca>] warn_slowpath_common+0x7a/0xb0
> > > > : [<ffffffff81018a18>] ? lapic_next_event+0x18/0x20
> > > > : [<ffffffff810323a1>] warn_slowpath_fmt+0x41/0x50
> > > > : [<ffffffff8104e9be>] ? hrtimer_interrupt+0xfe/0x1f0
> > > > : [<ffffffff8102c350>] ? wake_up_process+0x10/0x20
> > > > : [<ffffffff813e9397>] dev_watchdog+0x1e7/0x1f0
> > > > : [<ffffffff8103cfcf>] run_timer_softirq+0xef/0x210
> > > > : [<ffffffff813e91b0>] ? qdisc_reset+0x50/0x50
> > > > : [<ffffffff81037827>] __do_softirq+0x87/0x110
> > > > : [<ffffffff814945fa>] call_softirq+0x1a/0x30
> > > > : [<ffffffff810038bd>] do_softirq+0x4d/0x80
> > > > : [<ffffffff81037a8e>] irq_exit+0x7e/0xa0
> > > > : [<ffffffff8100375b>] do_IRQ+0x5b/0xd0
> > > > : [<ffffffff8148de29>] common_interrupt+0x69/0x69
> > > > : <EOI>  [<ffffffff8124e115>] ? acpi_idle_enter_bm+0x1c0/0x1ff
> > > > : [<ffffffff8124e110>] ? acpi_idle_enter_bm+0x1bb/0x1ff
> > > > : [<ffffffff813a24b4>] ? menu_select+0xd4/0x390
> > > > : [<ffffffff813a150b>] cpuidle_idle_call+0x8b/0xe0
> > > > : [<ffffffff810011ed>] cpu_idle+0x9d/0xe0
> > > > : [<ffffffff8147d08e>] rest_init+0x62/0x64
> > > > : [<ffffffff81699b54>] start_kernel+0x358/0x363
> > > > : [<ffffffff81699322>] x86_64_start_reservations+0x132/0x136
> > > > : [<ffffffff81699416>] x86_64_start_kernel+0xf0/0xf7
> > > > : [<ffffffff81017e70>] ? acpi_suspend_lowlevel+0x1b0/0x1b0
> > >=20
> > > We've seen this in Fedora for a long time now.  As far as I know,=
 nobody
> > > really knows what is going on.
> > >=20
> > > https://bugzilla.redhat.com/show_bug.cgi?id=3D717211
> > >=20
> > > (Also, you probably should have sent this to netdev.)
> >=20
> > CC netdev, Jay Cliburn <jcliburn@gmail.com>,=20
> >=20
> > It seems this driver has partial support for two TX rings.
> >=20
> > (TX completion only drains the first ring)
> >=20
> > Please try following patch.
> >=20
> > diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/driv=
ers/net/ethernet/atheros/atl1c/atl1c_main.c
> > index b859124..1ff3c6d 100644
> > --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> > +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> > @@ -2244,10 +2244,6 @@ static netdev_tx_t atl1c_xmit_frame(struct s=
k_buff *skb,
> >  			dev_info(&adapter->pdev->dev, "tx locked\n");
> >  		return NETDEV_TX_LOCKED;
> >  	}
> > -	if (skb->mark =3D=3D 0x01)
> > -		type =3D atl1c_trans_high;
> > -	else
> > -		type =3D atl1c_trans_normal;
> > =20
> >  	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
> >  		/* no enough descriptor, just stop queue */
> >=20
>=20
>=20
> Thomas, have you had the chance to test this patch ?
>=20

Bad news. Just did hit the issue again, with above patch applied.

abrt_version:   2.0.7
cmdline:        BOOT_IMAGE=3D/vmlinuz-3.2.6 root=3D/dev/sda2 rootfstype=
=3Dext4 rootflags=3Ddata=3Dwriteback ro quiet rhgb
kernel:         3.2.6
reason:         [177799.342250] WARNING: at net/sched/sch_generic.c:255=
 dev_watchdog+0x1e7/0x1f0()
time:           Di 21 Feb 2012 18:09:16 CET

backtrace:
:[177799.342250] WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0=
x1e7/0x1f0()
:[177799.342254] Hardware name: Aspire 1810T
:[177799.342256] NETDEV WATCHDOG: eth0 (atl1c): transmit queue 0 timed =
out
:[177799.342259] Modules linked in: vfat fat fuse bluetooth nf_conntrac=
k_ipv6 nf_defrag_ipv6 ip6t_REJECT ip6table_filter ip6_tables snd_hda_co=
dec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep sn=
d_seq arc4 snd_seq_device snd_pcm iwlwifi uvcvideo mac80211 snd_timer v=
ideodev cfg80211 snd usb_storage v4l2_compat_ioctl32 atl1c acer_wmi sou=
ndcore sparse_keymap snd_page_alloc rfkill wmi joydev acerhdf pcspkr vi=
rtio_net virtio virtio_ring kvm_intel kvm uinput ipv6 [last unloaded: s=
csi_wait_scan]
:[177799.342303] Pid: 4980, comm: alsa-sink Not tainted 3.2.6 #7
:[177799.342306] Call Trace:
:[177799.342309]  <IRQ>  [<ffffffff810322ca>] warn_slowpath_common+0x7a=
/0xb0
:[177799.342320]  [<ffffffff810323a1>] warn_slowpath_fmt+0x41/0x50
:[177799.342325]  [<ffffffff8100375b>] ? do_IRQ+0x5b/0xd0
:[177799.342330]  [<ffffffff813e94b7>] dev_watchdog+0x1e7/0x1f0
:[177799.342336]  [<ffffffff8103cfcf>] run_timer_softirq+0xef/0x210
:[177799.342341]  [<ffffffff813e92d0>] ? qdisc_reset+0x50/0x50
:[177799.342345]  [<ffffffff81037827>] __do_softirq+0x87/0x110
:[177799.342350]  [<ffffffff8149483a>] call_softirq+0x1a/0x30
:[177799.342354]  [<ffffffff810038bd>] do_softirq+0x4d/0x80
:[177799.342358]  [<ffffffff81037a8e>] irq_exit+0x7e/0xa0
:[177799.342363]  [<ffffffff8101903a>] smp_apic_timer_interrupt+0x5a/0x=
90
:[177799.342368]  [<ffffffff814942a9>] apic_timer_interrupt+0x69/0x70
:[177799.342371]  <EOI>  [<ffffffff814948d7>] ? sysenter_dispatch+0x7/0=
x26

END:
