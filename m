From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: mod_timer: list_add corruption: WARNING: CPU: 1 PID: 0 at lib/list_debug.c:33
 __list_add+0xbe/0xd0()
Date: Fri, 19 Jul 2013 14:38:03 +0530
Message-ID: <51E901F3.8010203@linux.vnet.ibm.com>
References: <51E557C0.2060602@linux.vnet.ibm.com> <51E8F759.4060202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51E8F759.4060202@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/19/2013 01:52 PM, Srivatsa S. Bhat wrote:
> On 07/16/2013 07:55 PM, Srivatsa S. Bhat wrote:
>> Hi,
>>
>> I happened to hit these warnings on an idle system shortly after
>> boot. And the machine locked up and sent NMIs to all CPUs, some of
>> which have been captured below.
>>
>> Kernel version: v3.11-rc1 + 3 unrelated local cpufreq patches.
>> Options set in .config (which are of interest here):
>>
>> CONFIG_TICK_ONESHOT=y
>> CONFIG_NO_HZ_COMMON=y
>> # CONFIG_HZ_PERIODIC is not set
>> # CONFIG_NO_HZ_IDLE is not set
>> CONFIG_NO_HZ_FULL=y
>> CONFIG_NO_HZ_FULL_ALL=y
>> CONFIG_NO_HZ=y
>> CONFIG_HIGH_RES_TIMERS=y
>>
>> CONFIG_TREE_RCU=y
>> # CONFIG_PREEMPT_RCU is not set
>> CONFIG_RCU_STALL_COMMON=y
>> CONFIG_CONTEXT_TRACKING=y
>> CONFIG_RCU_USER_QS=y
>> CONFIG_CONTEXT_TRACKING_FORCE=y
>> CONFIG_RCU_FANOUT=64
>> CONFIG_RCU_FANOUT_LEAF=16
>> # CONFIG_RCU_FANOUT_EXACT is not set
>> CONFIG_RCU_FAST_NO_HZ=y
>> # CONFIG_TREE_RCU_TRACE is not set
>> CONFIG_RCU_NOCB_CPU=y
>> CONFIG_RCU_NOCB_CPU_ALL=y
>>
>>
> 
> Today I hit the same warnings, even without NO_HZ_FULL enabled.
> I've attached my .config with this mail.
>

Adding netdev mailing list to CC.

I had posted the warnings here:
http://marc.info/?l=linux-kernel&m=137398492701587&w=2

Regards,
Srivatsa S. Bhat
