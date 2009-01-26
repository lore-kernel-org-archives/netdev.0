From: Greg KH <gregkh@suse.de>
Subject: Re: Linux 2.6.27.13
Date: Mon, 26 Jan 2009 13:07:30 -0800
Message-ID: <20090126210730.GB24164@suse.de>
References: <20090125004823.GA6711@kroah.com> <497E16A0.50607@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755091AbZAZVJc@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <497E16A0.50607@krogh.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2009 at 09:01:36PM +0100, Jesper Krogh wrote:
> Greg KH wrote:
>> We (the -stable team) are announcing the release of the 2.6.27.13
>> kernel.
>> It contains a wide range of bugfixes, and all users of the 2.6.27 kernel
>> series are strongly encouraged to upgrade.
>> I'll also be replying to this message with a copy of the patch between
>> 2.6.27.12 and 2.6.27.13
>
> Hi.
>
> I'm getting some e1000 noise on a 2.6.27.6, I search the log up to .13 but 
> couldn't find any log messsage that looked like it fixed it.
>
>
> [862734.501786] ------------[ cut here ]------------
> [862734.501793] WARNING: at net/sched/sch_generic.c:219 
> dev_watchdog+0x1f8/0x210()
> [862734.501795] NETDEV WATCHDOG: eth0 (e1000): transmit timed out

I've been getting a lot of reports about this as well.  Did it show up
in 2.6.27.6?

Netdev developers, any ideas of what would be causing this?

thanks,

greg k-h

(rest of the oops message below...)


> [862734.501796] Modules linked in: af_packet nfsd auth_rpcgss exportfs 
> autofs4 nfs lockd sunrpc ipv6 bonding iptable_filter ip_tables x_tables 
> lm87 adm1026 hwmon_vid ipmi_devintf ipmi_si ipmi_msghandler parport_pc lp 
> parport loop cfi_cmdset_0001 cfi_util jedec_probe cfi_probe psmouse 
> gen_probe serio_raw ck804xrom i2c_nforce2 mtd pcspkr chipreg shpchp 
> pci_hotplug i2c_core k8temp map_funcs joydev button evdev ext3 jbd mbcache 
> ide_cd_mod sr_mod cdrom sg usb_storage libusual ata_generic libata sd_mod 
> dock usbhid hid mptsas mptscsih qla2xxx mptbase scsi_transport_fc amd74xx 
> scsi_transport_sas ehci_hcd e1000 ohci_hcd scsi_mod ide_core usbcore 
> thermal processor fan thermal_sys fuse
> [862734.501837] Pid: 0, comm: swapper Not tainted 2.6.27.6 #2
> [862734.501839]
> [862734.501840] Call Trace:
> [862734.501842]  <IRQ>  [<ffffffff80237a7d>] warn_slowpath+0xcd/0x110
> [862734.501853]  [<ffffffff8022cc3d>] enqueue_task_fair+0x10d/0x110
> [862734.501857]  [<ffffffff8033b6fe>] rb_insert_color+0xde/0x110
> [862734.501859]  [<ffffffff8022ab83>] enqueue_task+0x13/0x30
> [862734.501861]  [<ffffffff8022adf7>] source_load+0x37/0x70
> [862734.501866]  [<ffffffff803370aa>] __next_cpu+0x1a/0x30
> [862734.501868]  [<ffffffff8022e093>] find_busiest_group+0x193/0x810
> [862734.501871]  [<ffffffff8033c76e>] strlcpy+0x4e/0x80
> [862734.501873]  [<ffffffff803e7340>] dev_watchdog+0x0/0x210
> [862734.501875]  [<ffffffff803e7538>] dev_watchdog+0x1f8/0x210
> [862734.501878]  [<ffffffff8024165b>] run_timer_softirq+0x1bb/0x230
> [862734.501881]  [<ffffffff8023cf46>] __do_softirq+0x76/0xf0
> [862734.501885]  [<ffffffff8020f17b>] profile_pc+0x3b/0x80
> [862734.501888]  [<ffffffff8020d51c>] call_softirq+0x1c/0x30
> [862734.501890]  [<ffffffff8020ee45>] do_softirq+0x35/0x70
> [862734.501894]  [<ffffffff8021ce80>] smp_apic_timer_interrupt+0x80/0xc0
> [862734.501897]  [<ffffffff8020cf66>] apic_timer_interrupt+0x66/0x70
> [862734.501898]  <EOI>  [<ffffffff802133e7>] default_idle+0x27/0x40
> [862734.501904]  [<ffffffff8021360a>] c1e_idle+0xba/0x100
> [862734.501906]  [<ffffffff8020adf4>] cpu_idle+0x44/0xb0
> [862734.501907]
> [862734.501909] ---[ end trace 8fad5965106e3cc6 ]---
>
> Complete dmesg here:
> http://krogh.cc/~jesper/dmesg-2.6.27.6.txt
>
> The system is running with bonded interfaces with  (lspi out put)
> 06:01.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:01.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:02.0 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
> 06:02.1 Ethernet controller: Intel Corporation 82546EB Gigabit Ethernet 
> Controller (Copper) (rev 03)
>
> The system is still "fully functional", and I havent notiched anything 
> wrong, but there sure is a lot of link ups and downs on that bond.
>
> -- 
> Jesper
