From: Ed Tomlinson <edt@aei.ca>
Subject: Re: Panic 2.6.24-3 Unable to handle kernel paging request
Date: Mon, 3 Mar 2008 22:19:58 -0500
Message-ID: <200803032219.58764.edt@aei.ca>
References: <200803010902.47997.edt@aei.ca> <200803031934.51944.edt@aei.ca> <20080303164359.2506fef1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763609AbYCDDUZ@vger.kernel.org>
In-Reply-To: <20080303164359.2506fef1.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On March 3, 2008, Andrew Morton wrote:
> On Mon, 3 Mar 2008 19:34:51 -0500
> Ed Tomlinson <edt@aei.ca> wrote:
> 
> > On March 1, 2008, Ed Tomlinson wrote:
> > 
> > Andrew,
> > 
> > Is there anyone else I should be copying on this? 
> > 
> 
> netdev@vger.kernel.org!
> 
> > > I have been seeing these since I installed 2.6.24.   Previous kernels (up to 2.6.23-5) have been ok.   Using the .24 kernels I get 
> > > from a minute to a few days of uptime.  Any ideas on what might be causing this?  
> > > 
> > > TIA,
> > > Ed Tomlinson
> > > 
> > > (2.6.24-gentoo-r2 + 2.6.24-3 patchset)
> > > grover login: [72899.939987] Unable to handle kernel paging request at 000000620000005e RIP: 
> > > [72899.953805]  [<000000620000005e>]
> > > [72899.971089] PGD 48cfa067 PUD 0 
> > > [72899.980552] Oops: 0010 [1] PREEMPT 
> > > [72899.991054] CPU 0 
> > > [72899.997110] Modules linked in: radeon ipv6 af_packet rfcomm l2cap snd_pcm_oss snd_mixer_oss snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device xfs hci_usb bluetooth usbhid pl2303 usbserial usbmouse ohci_hcd ehci_hcd video1394 w83627hf hwmon_vid i2c_nforce2 forcedeth sr_mod cdrom sbp2 radeonfb fb_ddc i2c_algo_bit i2c_core ohci1394 ieee1394 snd_intel8x0 snd_ac97_codec ac97_bus snd_pcm thermal processor snd_timer snd button soundcore snd_page_alloc parport_pc parport psmouse pcspkr evdev k8temp hwmon floppy rtc unix
> > > [72900.139457] Pid: 0, comm: swapper Not tainted 2.6.24-gentoo-r2-crc #2
> > > [72900.158744] RIP: 0010:[<000000620000005e>]  [<000000620000005e>]
> > > [72900.176758] RSP: 0018:ffffffff8062cbb8  EFLAGS: 00010202
> > > [72900.192666] RAX: 000000620000005e RBX: 0000000000000002 RCX: 0000000000000136
> > > [72900.214034] RDX: 0000000000000011 RSI: ffffffff8062cbf0 RDI: ffff810044e90100
> > > [72900.235400] RBP: ffffffff8062cc90 R08: ffff810044e90100 R09: ffffffff80672000
> > > [72900.256768] R10: 0000000000000103 R11: 0000000000000001 R12: ffff810044e90138
> > > [72900.278136] R13: 0000000000000002 R14: 0000000000000000 R15: ffff810044e90100
> > > [72900.299504] FS:  00002af955fe21d0(0000) GS:ffffffff805ed000(0000) knlGS:00000000f7d1c6c0
> > > [72900.323731] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> > > [72900.340939] CR2: 000000620000005e CR3: 000000004b2cc000 CR4: 00000000000006e0
> > > [72900.362306] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> > > [72900.383673] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> > > [72900.405042] Process swapper (pid: 0, threadinfo ffffffff805f6000, task ffffffff805ac360)
> > > [72900.429268] Stack:  ffffffff80476f61 ffffffff8062cbd0 0000000080227f4d ffffffff8062cbf0
> > > [72900.453443]  ffffffff80242fb1 ffff810002186fc0 ffff8100021857a8 0000000000000000
> > > [72900.475720]  0207a8c000000000 000000005b025257 0000000000000000 0000000000000000
> > > [72900.497425] Call Trace:
> > > [72900.505301]  <IRQ>  [<ffffffff80476f61>] __xfrm_policy_check+0x461/0x5b0
> > > [72900.525426]  [<ffffffff80242fb1>] autoremove_wake_function+0x11/0x40
> > > [72900.544455]  [<ffffffff80228a84>] __wake_up+0x84/0x90
> > > [72900.559579]  [<ffffffff8045d51a>] __udp4_lib_lookup+0x10a/0x160
> > > [72900.577309]  [<ffffffff8045e6b6>] __udp4_lib_rcv+0x6a6/0x8a0
> > > [72900.594257]  [<ffffffff80261ed0>] mempool_free+0x30/0xe0
> > > [72900.610165]  [<ffffffff802b2c5b>] bio_free+0x3b/0x50
> > > [72900.625035]  [<ffffffff80225be0>] __enqueue_entity+0x80/0x90
> > > [72900.641984]  [<ffffffff8045e8c5>] udp_rcv+0x15/0x20
> > > [72900.656592]  [<ffffffff8043aecb>] ip_local_deliver_finish+0xbb/0x230
> > > [72900.675619]  [<ffffffff8043b49b>] ip_local_deliver+0x3b/0x90
> > > [72900.692569]  [<ffffffff8043abb4>] ip_rcv_finish+0x124/0x380
> > > [72900.709256]  [<ffffffff80227f5b>] wake_up_state+0xb/0x10
> > > [72900.725164]  [<ffffffff80237dad>] signal_wake_up+0x1d/0x20
> > > [72900.741593]  [<ffffffff8043b372>] ip_rcv+0x1b2/0x2a0
> > > [72900.756463]  [<ffffffff80416740>] netif_receive_skb+0x250/0x4b0
> > > [72900.774192]  [<ffffffff80418ec5>] process_backlog+0x75/0xe0
> > > [72900.790883]  [<ffffffff8813cbb2>] :forcedeth:nv_alloc_rx+0xc2/0x1c0
> > > [72900.809647]  [<ffffffff80418a12>] net_rx_action+0x152/0x240
> > > [72900.826337]  [<ffffffff8023249a>] __do_softirq+0x5a/0xc0
> > > [72900.842245]  [<ffffffff8020c89c>] call_softirq+0x1c/0x30
> > > [72900.858152]  [<ffffffff8020da9d>] do_softirq+0x3d/0x90
> > > [72900.873542]  [<ffffffff802323c8>] irq_exit+0x88/0xa0
> > > [72900.888410]  [<ffffffff8020de52>] do_IRQ+0x62/0xc0
> > > [72900.902759]  [<ffffffff8020c0c1>] ret_from_intr+0x0/0xa
> > > [72900.918405]  <EOI>  [<ffffffff8024c99d>] tick_nohz_stop_sched_tick+0x1ad/0x2b0
> > > [72900.940062]  [<ffffffff8020a7e0>] poll_idle+0x0/0x10
> > > [72900.954929]  [<ffffffff8020a8aa>] cpu_idle+0x2a/0x90
> > > [72900.969798]  [<ffffffff8047ea79>] rest_init+0x69/0x70
> > > [72900.984930]  [<ffffffff805f9aaa>] start_kernel+0x25a/0x2a0
> > > [72901.001356]  [<ffffffff805f9107>] _sinittext+0x107/0x110
> 
> That's a bit cryptic.  Does it happen in 2.6.25-rc3?  If so, that kernel
> has extra info about the trace reliability.  Also, disbling
> CONFIG_FRAME_POINTER _should_ give a clean trace.

I have not tried 25-rc3, I'll build it with the above disabled and see what 
happens.

Thanks
Ed
