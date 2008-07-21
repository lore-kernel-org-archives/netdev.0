From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [BUG] kernel BUG at net/core/dev.c:1328!
Date: Mon, 21 Jul 2008 09:20:27 -0700 (PDT)
Message-ID: <20080721.092027.14394005.davem@davemloft.net>
References: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d4b984a30807210914nd4d0db5yb7b93ca5143ff0d5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Alessandro Guido" <ag-CnKWz401HL/3u/SXJKErtNrkRsMOXBsj@public.gmane.org>
Date: Mon, 21 Jul 2008 18:14:28 +0200

linux-wireless and netdev added to CC:

> this is what I get when try to det up a wireless connection with
> current git (v2.6.26-5253-g14b395e):
> 
> 
> kernel BUG at net/core/dev.c:1328!
> invalid opcode: 0000 [#1] PREEMPT
> Modules linked in: ipw2200
> 
> Pid: 5, comm: events/0 Not tainted (2.6.26-05253-g14b395e #1)
> EIP: 0060:[<c02e58ca>] EFLAGS: 00010246 CPU: 0
> EIP is at __netif_schedule+0x3a/0x40
> EAX: c043d380 EBX: eed84b40 ECX: c043d380 EDX: ffffffff
> ESI: eed84b44 EDI: ef808140 EBP: ef82bf64 ESP: ef82bf60
>  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> Process events/0 (pid: 5, ti=ef82b000 task=ef82cd40 task.ti=ef82b000)
> Stack: eed84b40 ef82bf80 f0939850 ef808140 ef82bf78 c02ef6c2 eed8584c ef808140
>        ef82bfa8 c012b02f ef82ce9c ee24fc00 ef82ce9c ffff007b f09396f0 ef808148
>        ef808140 ef82bfb0 ef82bfd0 c012b53f 00000000 ef82cd40 c012eaf0 ef82bfbc
> Call Trace:
>  [<f0939850>] ? ipw_bg_link_up+0x160/0x1f0 [ipw2200]
>  [<c02ef6c2>] ? rtnl_unlock+0x12/0x20
>  [<c012b02f>] ? run_workqueue+0x6f/0x160
>  [<f09396f0>] ? ipw_bg_link_up+0x0/0x1f0 [ipw2200]
>  [<c012b53f>] ? worker_thread+0x7f/0xe0
>  [<c012eaf0>] ? autoremove_wake_function+0x0/0x50
>  [<c012b4c0>] ? worker_thread+0x0/0xe0
>  [<c012e67a>] ? kthread+0x3a/0x70
>  [<c012e640>] ? kthread+0x0/0x70
>  [<c0103c8f>] ? kernel_thread_helper+0x7/0x18
>  =======================
> Code: 24 0f ba 28 01 19 d2 85 d2 75 1d 9c 5b fa a1 c0 11 4a c0 89 41
> 3c b8 02 00 00 00 89 0d c0 11 4a c0 e8 4b ab e3 ff 53 9d 5b 5d c3 <0f>
> 0b eb fe 66 90 55 89 e5 53 89 c3 8d 40 2c 0f ba 28 01 19 d2
> EIP: [<c02e58ca>] __netif_schedule+0x3a/0x40 SS:ESP 0068:ef82bf60
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
