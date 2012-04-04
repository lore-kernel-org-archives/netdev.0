From: Jean-Philippe Menil <jean-philippe.menil@univ-nantes.fr>
Subject: INFO: rcu_sched detected stall on CPU 0 (with whost module)
Date: Wed, 04 Apr 2012 16:47:04 +0200
Message-ID: <4F7C5EE8.2040501@univ-nantes.fr>
Reply-To: jean-philippe.menil@univ-nantes.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-tls1.univ-nantes.fr ([193.52.101.145]:59324 "EHLO
	smtp-tls.univ-nantes.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756428Ab2DDO4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:56:53 -0400
Received: from localhost (debian [127.0.0.1])
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTP id ED8C194E57
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2012 16:47:04 +0200 (CEST)
Received: from smtp-tls.univ-nantes.fr ([127.0.0.1])
	by localhost (smtp-tls1.d101.univ-nantes.fr [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id hu6mvVNgNBaQ for <netdev@vger.kernel.org>;
	Wed,  4 Apr 2012 16:47:04 +0200 (CEST)
Received: from [172.20.13.5] (antares.cri.univ-nantes.prive [172.20.13.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-tls.univ-nantes.fr (Postfix) with ESMTPSA id D16EC94DB2
	for <netdev@vger.kernel.org>; Wed,  4 Apr 2012 16:47:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

several times a day, i can observe the following trace:

Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600004]=
=20
INFO: rcu_sched detected stall on CPU 0 (t=3D6000 jiffies)
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
=20
Pid: 2487, comm: vhost-2475 Not tainted 3.2.1-dsiun-120113 #55
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
=20
Call Trace:
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
=20
<IRQ>  [<ffffffff810ac986>] ? __rcu_pending+0x1e6/0x400
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff810ace3b>] ? rcu_check_callbacks+0x6b/0x1d0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff810586df>] ? update_process_times+0x3f/0x80
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8107998b>] ? tick_sched_timer+0x5b/0xb0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8106d099>] ? __run_hrtimer+0x69/0x1e0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff81079930>] ? tick_nohz_handler+0xe0/0xe0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff81009e85>] ? read_tsc+0x5/0x20
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8106d9d5>] ? hrtimer_interrupt+0xe5/0x200
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8101f563>] ? smp_apic_timer_interrupt+0x63/0xa0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813ad79e>] ? apic_timer_interrupt+0x6e/0x80
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff812f1d01>] ? __kfree_skb+0x11/0x90
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa00d4437>] ? bnx2_poll_work+0x247/0x1370 [bnx2]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa00d4437>] ? bnx2_poll_work+0x247/0x1370 [bnx2]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813a6e7c>] ? put_cpu_partial+0x90/0x90
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8111b453>] ? kmem_cache_free+0x103/0x110
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa00d4437>] ? bnx2_poll_work+0x247/0x1370 [bnx2]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa00d5691>] ? bnx2_poll+0x61/0x264 [bnx2]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff812febd9>] ? net_rx_action+0x119/0x260
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8104fa1d>] ? __do_softirq+0x9d/0x1f0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813aef2c>] ? call_softirq+0x1c/0x30
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813aef2c>] ? call_softirq+0x1c/0x30
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
=20
<EOI>  [<ffffffff81004725>] ? do_softirq+0x65/0xa0
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff812ff05e>] ? netif_rx_ni+0x1e/0x30
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa04fb5af>] ? tun_get_user+0x30f/0x4c0 [tun]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa04fb780>] ? tun_sendmsg+0x20/0x30 [tun]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa051426e>] ? handle_tx+0x27e/0x4f0 [vhost_net]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa0511781>] ? vhost_worker+0xc1/0x150 [vhost_net]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffffa05116c0>] ? memory_access_ok.isra.11+0xd0/0xd0 [vhost_net]
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff8106905e>] ? kthread+0x7e/0x90
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813aee34>] ? kernel_thread_helper+0x4/0x10
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff81068fe0>] ? kthread_worker_fn+0x190/0x190
Apr  3 19:51:41 ayrshire.u06.univ-nantes.prive kernel: [1659525.600015]=
 =20
[<ffffffff813aee30>] ? gs_change+0x13/0x13
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950000]=
=20
INFO: rcu_sched detected stall on CPU 0 (t=3D6000 jiffies)
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
=20
Pid: 2485, comm: vhost-2475 Not tainted 3.2.1-dsiun-120113 #55
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
=20
Call Trace:
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
=20
<IRQ>  [<ffffffff810ac986>] ? __rcu_pending+0x1e6/0x400
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff810ace3b>] ? rcu_check_callbacks+0x6b/0x1d0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff810586df>] ? update_process_times+0x3f/0x80
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8107998b>] ? tick_sched_timer+0x5b/0xb0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8106d099>] ? __run_hrtimer+0x69/0x1e0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff81079930>] ? tick_nohz_handler+0xe0/0xe0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff81009e85>] ? read_tsc+0x5/0x20
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8106d9d5>] ? hrtimer_interrupt+0xe5/0x200
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8101f563>] ? smp_apic_timer_interrupt+0x63/0xa0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8111b1c7>] ? unfreeze_partials+0xc7/0x250
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff813ad79e>] ? apic_timer_interrupt+0x6e/0x80
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff812f1fc5>] ? skb_release_head_state+0xa5/0x110
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff813a6e33>] ? put_cpu_partial+0x47/0x90
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff812f1fc5>] ? skb_release_head_state+0xa5/0x110
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff812f1cf9>] ? __kfree_skb+0x9/0x90
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa00d4437>] ? bnx2_poll_work+0x247/0x1370 [bnx2]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa00d5691>] ? bnx2_poll+0x61/0x264 [bnx2]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8134e3d0>] ? tcp_init_xmit_timers+0x20/0x20
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff812febd9>] ? net_rx_action+0x119/0x260
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8104fa1d>] ? __do_softirq+0x9d/0x1f0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff813aef2c>] ? call_softirq+0x1c/0x30
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
=20
<EOI>  [<ffffffff81004725>] ? do_softirq+0x65/0xa0
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff812ff05e>] ? netif_rx_ni+0x1e/0x30
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa04fb5af>] ? tun_get_user+0x30f/0x4c0 [tun]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa04fb780>] ? tun_sendmsg+0x20/0x30 [tun]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa051426e>] ? handle_tx+0x27e/0x4f0 [vhost_net]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa0511781>] ? vhost_worker+0xc1/0x150 [vhost_net]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffffa05116c0>] ? memory_access_ok.isra.11+0xd0/0xd0 [vhost_net]
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff8106905e>] ? kthread+0x7e/0x90
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff813aee34>] ? kernel_thread_helper+0x4/0x10
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff81068fe0>] ? kthread_worker_fn+0x190/0x190
Apr  3 19:59:23 ayrshire.u06.univ-nantes.prive kernel: [1659986.950014]=
 =20
[<ffffffff813aee30>] ? gs_change+0x13/0x13

This host run several kvm (with multiple tun/tap devices attached on=20
bridge) with the vhost module with experimental_zcopytx to 1

Both eth0 and eth2 are BCM5708S, with followinf parameter:
root@ayrshire:~# ethtool -k eth0
Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: on

root@ayrshire:~# ethtool -i eth0
driver: bnx2
version: 2.1.11
firmware-version: 5.2.7 bc 5.0.5
bus-info: 0000:04:00.0

Is it a know issue?

Regards


--=20
Jean-Philippe Menil - P=F4le r=E9seau Service IRTS
DSI Universit=E9 de Nantes
jean-philippe.menil@univ-nantes.fr
Tel : 02.53.48.49.27 - Fax : 02.53.48.49.09
