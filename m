From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: 2.6.27-05178-g2e532d6: list_add corruption
Date: Fri, 17 Oct 2008 16:19:13 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0810171617490.21410@alien.or.mcafeemobile.com>
References: <a4423d670810171220t4d5602fekcb66e18758149925@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758200AbYJQXTY@vger.kernel.org>
In-Reply-To: <a4423d670810171220t4d5602fekcb66e18758149925@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Oct 2008, Alexander Beregalov wrote:

> I am afraid I do not know how to reproduce this.
> 
> WARNING: at lib/list_debug.c:30 __list_add+0x44/0x5c()
> list_add corruption. prev->next should be next (f6638448), but was
> f26f078c. (prev=f26f078c).
> Modules linked in: w83627hf hwmon_vid i2c_nforce2
> Pid: 1933, comm: rtorrent Not tainted 2.6.27-05178-g2e532d6 #6
> Call Trace:
>  [<c011de4b>] warn_slowpath+0x4b/0x69
>  [<c0137a03>] ? trace_hardirqs_off+0xb/0xd
>  [<c01070ab>] ? native_sched_clock+0x76/0x88
>  [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
>  [<c0138c93>] ? trace_hardirqs_on_caller+0xe6/0x10d
>  [<c031aa43>] ? release_sock+0xac/0xb4
>  [<c0138cc5>] ? trace_hardirqs_on+0xb/0xd
>  [<c0139d4e>] ? __lock_acquire+0xaeb/0xafa
>  [<c0139d4e>] ? __lock_acquire+0xaeb/0xafa
>  [<c0137a39>] ? put_lock_stats+0xd/0x21
>  [<c026a404>] __list_add+0x44/0x5c
>  [<c0186be0>] ep_poll_callback+0x5b/0xb4

This is very likely to be caused by a patch that went in a few days ago. 
Already posted a fix to Andrew.



- Davide
