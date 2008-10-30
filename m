From: Stefan Hellermann <stefan-/Cgo3cKJSaJlwAJJmLIKuQ@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-10-29
Date: Thu, 30 Oct 2008 15:48:30 +0100
Message-ID: <4909C93E.7020400@the2masters.de>
References: <20081029231855.GD3485@tuxdriver.com> <20081029162324.28f5864d@infradead.org> <20081029233350.GE3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org, mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081029233350.GE3485-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville schrieb:
> On Wed, Oct 29, 2008 at 04:23:24PM -0700, Arjan van de Ven wrote:
>   
>> On Wed, 29 Oct 2008 19:18:55 -0400
>> "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>>
>>     
>>> Dave,
>>>
>>> Another quick round of fixes intended for 2.6.28...
>>>
>>> This includes fixes for bugs 11749 and 11845, fixes a reset-related
>>> regression in ath5k, fixes a Kconfig-related error for rt2x00, and
>>> fixes some sparse warnings and a possible buffer overrun in libertas.
>>> Also, it corrects a spelling error and marks Bob Copeland as an
>>> ath5k maintainer.
>>>       
>> speaking of ath5k:
>>
>> http://www.kerneloops.org/version.php?start=1835008&end=1867775&version=28-rc
>>
>> it seems to have added a few WARN_ON()s which now end up at the top of
>> the list .. are these known or should I spend some time writing reports
>> for netdev ?
>>     
>
> I wasn't aware of them -- thanks... :-)
>
>   
I think some of the reports on kerneloops are from my machine, I'm
running wireless-testing#master in the hope to get my card fully
working. It's a AR2425 chip (MAC: 0xe2, PHY: 0x70), in a Lenovo Notebook.

The wireless-connection is nearly unusable. I can provide access to this
machine or test patches if anyone can help.

I get many warnings like

WARNING: at /srv/devel/kernel/net/mac80211/rx.c:2203
ath5k_tasklet_rx+0x318/0x5c0()
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.28-rc1-wl #46
Call Trace:
 [<c014744f>] warn_on_slowpath+0x5f/0xa0
 [<c013ef69>] enqueue_task_fair+0xb9/0x100
 [<c013ef69>] enqueue_task_fair+0xb9/0x100
 [<c0137835>] default_spin_lock_flags+0x5/0x10
 [<c0574fbb>] _spin_lock_irqsave+0x2b/0x40
 [<c0151347>] lock_timer_base+0x27/0x60
 [<c01514e0>] __mod_timer+0x90/0xa0
 [<c03e8dea>] rexmit_timer+0x36a/0x3d0
 [<c03aebe8>] ath5k_tasklet_rx+0x318/0x5c0
 [<c014bfb0>] tasklet_action+0x70/0x100
 [<c014ca97>] __do_softirq+0x97/0x160
 [<c014ca00>] __do_softirq+0x0/0x160
 <IRQ>  [<c0170c50>] handle_fasteoi_irq+0x0/0xe0
 [<c014c7bd>] irq_exit+0x5d/0x80
 [<c012297c>] do_IRQ+0xcc/0x100
 [<c0120aeb>] common_interrupt+0x23/0x28
 [<c0334f88>] acpi_idle_enter_bm+0x315/0x39e
 [<c04346c4>] cpuidle_idle_call+0x74/0xc0
 [<c011eded>] cpu_idle+0x6d/0xd0
---[ end trace 8ac847f454371229 ]---

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
