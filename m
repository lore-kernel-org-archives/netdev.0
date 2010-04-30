From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH linux-next v3 1/2] irq: Add CPU mask affinity hint
Date: Fri, 30 Apr 2010 13:30:52 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.1004301329390.6532@PPWASKIE-MOBL2.amr.corp.intel.com>
References: <20100430202343.4591.66240.stgit@ppwaskie-hc2.jf.intel.com>
 <alpine.LFD.2.00.1004302220270.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1004302220270.2951@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 30 Apr 2010, Thomas Gleixner wrote:

> Peter,
>
> On Fri, 30 Apr 2010, Peter P Waskiewicz Jr wrote:
>>
>> +extern int irq_register_affinity_hint(unsigned int irq,
>> +                                      const struct cpumask *m);
>
> One last nitpick.
>
> Can you please rename to irq_set_affinity_hint() ?

Not a problem.  It's a better name anyways now that we've dropped the 
callback function.  Patch update incoming.

>
> Otherwise, I'm happy with the outcome. Thanks for your patience!

Thanks for your help getting this pulled together.  This is a big step for 
our performance tuning goals.

Cheers,
-PJ
