From: Andi Kleen <ak@suse.de>
Subject: Re: kernel performance update - 2.6.14-rc3
Date: 06 Oct 2005 12:32:11 +0200
Message-ID: <p73mzlnylzo.fsf@verdi.suse.de>
References: <200510052115.j95LFgg07836@unix-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750797AbVJFKcP@vger.kernel.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
In-Reply-To: <200510052115.j95LFgg07836@unix-os.sc.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Chen, Kenneth W" <kenneth.w.chen@intel.com> writes:

> Even though
> softirq is invoked at the end of dev_queue_xmit() via local_bh_enable(),
> not all execution of softirq will result a __wake_up().  With higher
> HZ rate, timer interrupt is more frequent and thus more softirq
> invocation and leads to more __wake_up(), which then takes us to higher
> throughput because cpu spend less time in idle.  

This sounds like a serious bug somewhere if true.

-Andi
