From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [AX25] kernel panic
Date: Wed, 23 Sep 2009 23:17:12 +0200
Message-ID: <4ABA9058.3010605@free.fr>
References: <20090921201157.GA5460@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: Bernard Pidoux <bernard.pidoux@upmc.fr>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-hams <linux-hams@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090921201157.GA5460@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jarek,

After applying your second patch I had to wait until today before I catched
these kernel messages.
The last three ones where single lines.
There was no kernel panic. 

Sep 23 10:13:53 f6bvp-11 klogd: ------------[ cut here ]------------
Sep 23 10:13:53 f6bvp-11 klogd: WARNING: at net/ax25/af_ax25.c:241 ax25_find_cb+0x170/0x1a0 [ax25]()
Sep 23 10:13:53 f6bvp-11 klogd: Hardware name: MS-7258
Sep 23 10:13:53 f6bvp-11 klogd: Modules linked in: netconsole netrom mkiss rose ax25 nfsd exportfs nfs l
ockd nfs_acl auth_rpcgss sunrpc af_packet ipv6 snd_via82xx snd_ac97_codec ac97_bus snd_mpu401_uart snd_r
awmidi snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_pcm snd_timer
 snd_page_alloc 8139cp snd_mixer_oss 8139too snd i2c_viapro i2c_core soundcore shpchp sr_mod mii pci_hot
plug binfmt_misc ext3 jbd cpufreq_ondemand cpufreq_conservative cpufreq_powersave acpi_cpufreq freq_tabl
e processor floppy sg rtc_cmos evdev button thermal via_agp pata_via ata_generic ide_pci_generic pata_ac
pi sata_via libata sd_mod scsi_mod crc_t10dif
Sep 23 10:13:53 f6bvp-11 klogd: Pid: 5, comm: events/0 Not tainted 2.6.31-nosmp #3
Sep 23 10:13:53 f6bvp-11 klogd: Call Trace:
Sep 23 10:13:53 f6bvp-11 klogd:  <IRQ>  [<ffffffffa03b40d0>] ? ax25_find_cb+0x170/0x1a0 [ax25]
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff81053b90>] warn_slowpath_common+0x80/0xe0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff81053c12>] warn_slowpath_null+0x22/0x40
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffffa03b40d0>] ax25_find_cb+0x170/0x1a0 [ax25]
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffffa03aced5>] ? ax25_listen_mine+0x95/0xb0 [ax25]
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffffa03ad299>] ax25_kiss_rcv+0x199/0xac0 [ax25]
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8132b4bd>] ? sock_def_readable+0x3d/0x80
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8132c96d>] ? sock_queue_rcv_skb+0x12d/0x160
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8133a831>] netif_receive_skb+0x351/0x5f0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff81061699>] ? run_timer_softirq+0x179/0x250
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8133ab50>] process_backlog+0x80/0xe0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8133b4a4>] net_rx_action+0xf4/0x220
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8105b242>] __do_softirq+0xe2/0x1d0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8101414a>] call_softirq+0x1a/0x30
Sep 23 10:13:53 f6bvp-11 klogd:  <EOI>  [<ffffffff810162c5>] do_softirq+0x75/0xc0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8105b094>] local_bh_enable+0xc4/0xd0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffffa03cf798>] mkiss_receive_buf+0x3a8/0x460 [mkiss]
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8104b864>] ? finish_task_switch+0x44/0xe0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff812af800>] flush_to_ldisc+0x110/0x1f0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8106c71c>] ? schedule_delayed_work+0x2c/0x50
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff812af6f0>] ? flush_to_ldisc+0x0/0x1f0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8106c263>] worker_thread+0x173/0x260
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff81071be0>] ? autoremove_wake_function+0x0/0x60
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8106c0f0>] ? worker_thread+0x0/0x260
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8107149e>] kthread+0xae/0xc0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff8101404a>] child_rip+0xa/0x20
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff810713f0>] ? kthread+0x0/0xc0
Sep 23 10:13:53 f6bvp-11 klogd:  [<ffffffff81014040>] ? child_rip+0x0/0x20
Sep 23 10:13:53 f6bvp-11 klogd: ---[ end trace 422da9fe354a7ce3 ]---
Sep 23 10:13:53 f6bvp-11 klogd: AX25_DBG: 1 ffff880003c80000 0 ax25_find_cb
Sep 23 10:13:53 f6bvp-11 last message repeated 2 times

-----

Sep 23 14:26:56 f6bvp-11 klogd: AX25_DBG: 1 ffff88005247b000 0 ax25_find_cb
Sep 23 14:26:56 f6bvp-11 klogd: AX25_DBG: 1 ffff88005247b000 0 ax25_find_cb
Sep 23 14:26:56 f6bvp-11 klogd: AX25_DBG: 1 ffff88005247b000 0 ax25_find_cb

-----

Regards, 

Bernard



Jarek Poplawski a e'crit :
> <20090910142436.GB10547@linux-mips.org> <4AA9288B.2070205@upmc.fr>
> <20090911120557.GA12175@linux-mips.org> <4AB5EAE5.6070605@upmc.fr>
> <20090920210242.GA9804@del.dom.local> <4AB73CDE.4030709@upmc.fr>
> In-Reply-To: <4AB73CDE.4030709@upmc.fr>
> 
> Bernard Pidoux wrote, On 09/21/2009 10:44 AM:
> 
>> Hi Jarek,
>>
>> Good fishing !
>>
>> During the night I catched the following two identical AX25_DBG
>> messages with netconsole
>> sending already reported message: kernel BUG at kernel/timer.c:913!
>> and followed by kernel
>> panics and the machine rebooting.
>>
>>
>> Sep 21 03:24:06 f6bvp-11 klogd: ------------[ cut here ]------------
>> Sep 21 03:24:06 f6bvp-11 klogd: WARNING: at include/net/ax25.h:260
>> ax25_kiss_rcv+0x650/0xab0 [ax25]()
> 
> Thanks for testing. Alas I don't get how it's possible at this place
> (unless I miss the place), especially with a nosmp kernel. So here is
> take 2 (to apply after reverting the previous one).
> 
> Regards,
> Jarek P.
> --- (debugging patch, take 2)
> 
>  include/net/ax25.h |   36 ++++++++++++++++++++++++++++++++++++
>  net/ax25/af_ax25.c |   12 ++++++++++++
>  2 files changed, 48 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/ax25.h b/include/net/ax25.h
> index 717e219..7fefbb0 100644
> --- a/include/net/ax25.h
> +++ b/include/net/ax25.h
> @@ -252,9 +252,45 @@ typedef struct ax25_cb {
>  #define ax25_cb_hold(__ax25) \
>  	atomic_inc(&((__ax25)->refcount))
>  
> +static __inline__ int ax25_timers_warn(ax25_cb *ax25)
> +{
> +	int err = 0;
> +
> +	if (del_timer(&ax25->timer)) {
> +		WARN_ON_ONCE(1);
> +		err = 1;
> +	}
> +	if (del_timer(&ax25->t1timer)) {
> +		WARN_ON_ONCE(1);
> +		err += 2;
> +	}
> +	if (del_timer(&ax25->t2timer)) {
> +		WARN_ON_ONCE(1);
> +		err += 4;
> +	}
> +	if (del_timer(&ax25->t3timer)) {
> +		WARN_ON_ONCE(1);
> +		err += 8;
> +	}
> +	if (del_timer(&ax25->idletimer)) {
> +		WARN_ON_ONCE(1);
> +		err += 16;
> +	}
> +	if (del_timer(&ax25->dtimer)) {
> +		WARN_ON_ONCE(1);
> +		err += 32;
> +	}
> +	if (err)
> +		printk(KERN_WARNING "AX25_DBG: %d %p %u %s %d\n", err, ax25,
> +		       ax25->state, __func__, __LINE__);
> +
> +	return err;
> +}
> +
>  static __inline__ void ax25_cb_put(ax25_cb *ax25)
>  {
>  	if (atomic_dec_and_test(&ax25->refcount)) {
> +		ax25_timers_warn(ax25);
>  		kfree(ax25->digipeat);
>  		kfree(ax25);
>  	}
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
> index da0f64f..f1f515c 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -58,6 +58,9 @@ static const struct proto_ops ax25_proto_ops;
>  
>  static void ax25_free_sock(struct sock *sk)
>  {
> +	if (ax25_timers_warn(ax25_sk(sk)))
> +		printk(KERN_WARNING "AX25_DBG: %p %u %u %u\n", sk,
> +		       sk->sk_family, sk->sk_type, sk->sk_protocol);
>  	ax25_cb_put(ax25_sk(sk));
>  }
>  
> @@ -222,6 +225,8 @@ ax25_cb *ax25_find_cb(ax25_address *src_addr, ax25_address *dest_addr,
>  		if (s->ax25_dev == NULL)
>  			continue;
>  		if (ax25cmp(&s->source_addr, src_addr) == 0 && ax25cmp(&s->dest_addr, dest_addr) == 0 && s->ax25_dev->dev == dev) {
> +			int ref;
> +
>  			if (digi != NULL && digi->ndigi != 0) {
>  				if (s->digipeat == NULL)
>  					continue;
> @@ -231,6 +236,13 @@ ax25_cb *ax25_find_cb(ax25_address *src_addr, ax25_address *dest_addr,
>  				if (s->digipeat != NULL && s->digipeat->ndigi != 0)
>  					continue;
>  			}
> +			ref = atomic_read(&s->refcount);
> +			if (ref < 2) {
> +				WARN_ON_ONCE(1);
> +				printk(KERN_WARNING "AX25_DBG: %d %p %d %s\n",
> +				       ref, s, s->state, __func__);
> +			}
> +
>  			ax25_cb_hold(s);
>  			spin_unlock_bh(&ax25_list_lock);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-hams" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

