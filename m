From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 00/46] CPU hotplug: stop_machine()-free CPU hotplug
Date: Tue, 26 Feb 2013 03:15:05 +0530
Message-ID: <512BDB61.1010204@linux.vnet.ibm.com>
References: <20130218123714.26245.61816.stgit@srivatsabhat.in.ibm.com> <87mwuxfatp.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, mingo@kernel.org,
	akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	walken@google.com, vincent.guittot@linaro.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <87mwuxfatp.fsf@rustcorp.com.au>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/22/2013 06:01 AM, Rusty Russell wrote:
> "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com> writes:
>> Hi,
>>
>> This patchset removes CPU hotplug's dependence on stop_machine() from the CPU
>> offline path and provides an alternative (set of APIs) to preempt_disable() to
>> prevent CPUs from going offline, which can be invoked from atomic context.
>> The motivation behind the removal of stop_machine() is to avoid its ill-effects
>> and thus improve the design of CPU hotplug. (More description regarding this
>> is available in the patches).
> 
> If you're doing a v7, please put your benchmark results somewhere!
> 

Oh, I forgot to put them in v6! Thanks for reminding :-)
And yes, I'll have to do a v7 to incorporate changes (if any) to the new code
that went in during this merge window.

> The obvious place is in the 44/46.
>

Ok, will add it there. Thank you!
 
Regards,
Srivatsa S. Bhat

