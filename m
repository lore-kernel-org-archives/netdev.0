From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WARNING] Network-related warnings with 2.6.31.6
Date: Wed, 02 Dec 2009 05:52:12 +0100
Message-ID: <4B15F27C.9020707@gmail.com>
References: <43332.67750.qm@web52904.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755325AbZLBEwL@vger.kernel.org>
In-Reply-To: <43332.67750.qm@web52904.mail.re2.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Rankin a =C3=A9crit :
> Hi,
>=20
> I've just noticed these warnings in my dmesg log, and have no idea wh=
at might have triggered them. e1000 related, perhaps?
>=20
> Cheers,
> Chris
>=20
> ------------[ cut here ]------------
> WARNING: at /home/chris/LINUX/linux-2.6.31/net/core/stream.c:202 inet=
_csk_destroy_sock+0x77/0xd3()
> Hardware name: Precision WorkStation 650   =20
> Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nf=
sd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_connt=
rack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack=
_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4=
_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_=
mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_mid=
i_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97=
_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer f=
irewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_uti=
l_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc=
_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcac=
he sr_mod cdrom sd_mod pata_acpi sata_sil uhci_hcd ata_piix libata scsi=
_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agp=
gart i2c_algo_bit cfbcopyarea cfbimgblt
>  cfbfillrect [last unloaded: processor]
> Pid: 32056, comm: rpm Not tainted 2.6.31.6 #1
> Call Trace:
>  [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
>  [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
>  [<c11871ca>] ? inet_csk_destroy_sock+0x77/0xd3
>  [<c119188f>] ? tcp_rcv_state_process+0x81f/0x9e8
>  [<c11966c3>] ? tcp_v4_do_rcv+0x128/0x16d
>  [<c1196b0d>] ? tcp_v4_rcv+0x405/0x640
>  [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
>  [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
>  [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
>  [<c116b7c5>] ? netif_receive_skb+0x261/0x281
>  [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
>  [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
>  [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
>  [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
>  [<c11c769b>] ? _spin_lock_irq+0xe/0x24
>  [<c116bce5>] ? net_rx_action+0x57/0xfd
>  [<c1027ea3>] ? __do_softirq+0x7a/0xe3
>  [<c1027e29>] ? __do_softirq+0x0/0xe3
>  <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
>  [<c1004320>] ? do_IRQ+0x7c/0x8d
>  [<c1002f29>] ? common_interrupt+0x29/0x30
> ---[ end trace e643d9455a26ccf3 ]---
> ------------[ cut here ]------------
> WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:151 ine=
t_sock_destruct+0xd8/0x138()
> Hardware name: Precision WorkStation 650   =20
> Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nf=
sd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_connt=
rack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack=
_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4=
_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_=
mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_mid=
i_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97=
_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer f=
irewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_uti=
l_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc=
_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcac=
he sr_mod cdrom sd_mod pata_acpi sata_sil uhci_hcd ata_piix libata scsi=
_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agp=
gart i2c_algo_bit cfbcopyarea cfbimgblt
>  cfbfillrect [last unloaded: processor]
> Pid: 32056, comm: rpm Tainted: G        W  2.6.31.6 #1
> Call Trace:
>  [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
>  [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
>  [<c11a1414>] ? inet_sock_destruct+0xd8/0x138
>  [<c1163243>] ? __sk_free+0x10/0xa2
>  [<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
>  [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
>  [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
>  [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
>  [<c116b7c5>] ? netif_receive_skb+0x261/0x281
>  [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
>  [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
>  [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
>  [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
>  [<c11c769b>] ? _spin_lock_irq+0xe/0x24
>  [<c116bce5>] ? net_rx_action+0x57/0xfd
>  [<c1027ea3>] ? __do_softirq+0x7a/0xe3
>  [<c1027e29>] ? __do_softirq+0x0/0xe3
>  <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
>  [<c1004320>] ? do_IRQ+0x7c/0x8d
>  [<c1002f29>] ? common_interrupt+0x29/0x30
> ---[ end trace e643d9455a26ccf4 ]---
> ------------[ cut here ]------------
> WARNING: at /home/chris/LINUX/linux-2.6.31/net/ipv4/af_inet.c:154 ine=
t_sock_destruct+0x11e/0x138()
> Hardware name: Precision WorkStation 650   =20
> Modules linked in: tun snd_seq_oss snd_seq_midi snd_seq_dummy fuse nf=
sd lockd auth_rpcgss exportfs sunrpc autofs4 af_packet ipt_LOG nf_connt=
rack_ipv4 nf_defrag_ipv4 iptable_filter ip_tables ip6t_LOG nf_conntrack=
_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables x_tables ipv6 p4=
_clockmod speedstep_lib binfmt_misc dm_mirror dm_region_hash dm_log dm_=
mod uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi snd_seq_mid=
i_event snd_seq_midi_emul snd_emu10k1 snd_ac97_codec snd_usb_audio ac97=
_bus snd_seq snd_pcm snd_usb_lib snd_rawmidi snd_seq_device snd_timer f=
irewire_ohci ppdev uvcvideo floppy firewire_core snd_page_alloc snd_uti=
l_mem snd_hwdep parport_pc pwc psmouse videodev parport v4l1_compat crc=
_itu_t pcspkr snd sg i2c_i801 serio_raw soundcore dcdbas ext3 jbd mbcac=
he sr_mod cdrom sd_mod pata_acpi sata_sil uhci_hcd ata_piix libata scsi=
_mod ehci_hcd e1000 usbcore thermal button radeon intel_agp ttm drm agp=
gart i2c_algo_bit cfbcopyarea cfbimgblt
>  cfbfillrect [last unloaded: processor]
> Pid: 32056, comm: rpm Tainted: G        W  2.6.31.6 #1
> Call Trace:
>  [<c1023ba8>] ? warn_slowpath_common+0x5d/0x70
>  [<c1023bc6>] ? warn_slowpath_null+0xb/0xd
>  [<c11a145a>] ? inet_sock_destruct+0x11e/0x138
>  [<c1163243>] ? __sk_free+0x10/0xa2
>  [<c1196b4a>] ? tcp_v4_rcv+0x442/0x640
>  [<c118003e>] ? ip_local_deliver_finish+0xf3/0x1ab
>  [<c117fcd9>] ? ip_rcv_finish+0x2a9/0x2cf
>  [<c117fa30>] ? ip_rcv_finish+0x0/0x2cf
>  [<c116b7c5>] ? netif_receive_skb+0x261/0x281
>  [<f8527bfc>] ? e1000_clean_rx_irq+0x31c/0x3c3 [e1000]
>  [<f852a6fa>] ? e1000_clean+0x2a7/0x3f5 [e1000]
>  [<c11c783c>] ? _spin_unlock_irqrestore+0xe/0x21
>  [<c10354c0>] ? hrtimer_run_pending+0xd/0xa5
>  [<c11c769b>] ? _spin_lock_irq+0xe/0x24
>  [<c116bce5>] ? net_rx_action+0x57/0xfd
>  [<c1027ea3>] ? __do_softirq+0x7a/0xe3
>  [<c1027e29>] ? __do_softirq+0x0/0xe3
>  <IRQ>  [<c1027c3c>] ? irq_exit+0x29/0x63
>  [<c1004320>] ? do_IRQ+0x7c/0x8d
>  [<c1002f29>] ? common_interrupt+0x29/0x30
> ---[ end trace e643d9455a26ccf5 ]---
>=20
>=20
>=20


Hmm, one other sk_forward_alloc corruption I guess...

I fixed one corruption but this is only about UDP sockets used by SUNRP=
C,
while your traces seems to point a TCP problem.


This is a note to let you know that we have just queued up the patch ti=
tled

    Subject: net: fix sk_forward_alloc corruption

to the 2.6.31-stable tree.  Its filename is

    net-fix-sk_forward_alloc-corruption.patch

A git repo of this tree can be found at=20
    http://www.kernel.org/git/?p=3Dlinux/kernel/git/stable/stable-queue=
=2Egit;a=3Dsummary


=46rom 4432366eece70b6cf72a7e862945ea8c9e576e3d Mon Sep 17 00:00:00 200=
1
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 15 Nov 2009 20:50:00 -0800
Subject: net: fix sk_forward_alloc corruption

=46rom: Eric Dumazet <eric.dumazet@gmail.com>

[ Upstream commit: 9d410c796067686b1e032d54ce475b7055537138 ]

On UDP sockets, we must call skb_free_datagram() with socket locked,
or risk sk_forward_alloc corruption. This requirement is not respected
in SUNRPC.

Add a convenient helper, skb_free_datagram_locked() and use it in SUNRP=
C

Reported-by: Francis Moreau <francis.moro@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---
 include/linux/skbuff.h |    2 ++
 net/core/datagram.c    |   10 +++++++++-
 net/ipv4/udp.c         |    4 +---
 net/ipv6/udp.c         |    4 +---
 net/sunrpc/svcsock.c   |   10 +++++-----
 5 files changed, 18 insertions(+), 12 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1761,6 +1761,8 @@ extern int	       skb_copy_datagram_cons
 						     int to_offset,
 						     int size);
 extern void	       skb_free_datagram(struct sock *sk, struct sk_buff *=
skb);
+extern void	       skb_free_datagram_locked(struct sock *sk,
+						struct sk_buff *skb);
 extern int	       skb_kill_datagram(struct sock *sk, struct sk_buff *s=
kb,
 					 unsigned int flags);
 extern __wsum	       skb_checksum(const struct sk_buff *skb, int offse=
t,
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -223,6 +223,15 @@ void skb_free_datagram(struct sock *sk,=20
 	consume_skb(skb);
 	sk_mem_reclaim_partial(sk);
 }
+EXPORT_SYMBOL(skb_free_datagram);
+
+void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
+{
+	lock_sock(sk);
+	skb_free_datagram(sk, skb);
+	release_sock(sk);
+}
+EXPORT_SYMBOL(skb_free_datagram_locked);
=20
 /**
  *	skb_kill_datagram - Free a datagram skbuff forcibly
@@ -749,5 +758,4 @@ unsigned int datagram_poll(struct file *
 EXPORT_SYMBOL(datagram_poll);
 EXPORT_SYMBOL(skb_copy_and_csum_datagram_iovec);
 EXPORT_SYMBOL(skb_copy_datagram_iovec);
-EXPORT_SYMBOL(skb_free_datagram);
 EXPORT_SYMBOL(skb_recv_datagram);
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -987,9 +987,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	skb_free_datagram_locked(sk, skb);
 out:
 	return err;
=20
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -288,9 +288,7 @@ try_again:
 		err =3D ulen;
=20
 out_free:
-	lock_sock(sk);
-	skb_free_datagram(sk, skb);
-	release_sock(sk);
+	skb_free_datagram_locked(sk, skb);
 out:
 	return err;
=20
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -110,7 +110,7 @@ static void svc_release_skb(struct svc_r
 		rqstp->rq_xprt_ctxt =3D NULL;
=20
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 	}
 }
=20
@@ -537,7 +537,7 @@ static int svc_udp_recvfrom(struct svc_r
 			printk("rpcsvc: received unknown control message:"
 			       "%d/%d\n",
 			       cmh->cmsg_level, cmh->cmsg_type);
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 		return 0;
 	}
 	svc_udp_get_dest_address(rqstp, cmh);
@@ -548,18 +548,18 @@ static int svc_udp_recvfrom(struct svc_r
 		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
 			local_bh_enable();
 			/* checksum error */
-			skb_free_datagram(svsk->sk_sk, skb);
+			skb_free_datagram_locked(svsk->sk_sk, skb);
 			return 0;
 		}
 		local_bh_enable();
-		skb_free_datagram(svsk->sk_sk, skb);
+		skb_free_datagram_locked(svsk->sk_sk, skb);
 	} else {
 		/* we can use it in-place */
 		rqstp->rq_arg.head[0].iov_base =3D skb->data +
 			sizeof(struct udphdr);
 		rqstp->rq_arg.head[0].iov_len =3D len;
 		if (skb_checksum_complete(skb)) {
-			skb_free_datagram(svsk->sk_sk, skb);
+			skb_free_datagram_locked(svsk->sk_sk, skb);
 			return 0;
 		}
 		rqstp->rq_xprt_ctxt =3D skb;
