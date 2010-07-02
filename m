From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH repost] sched: export sched_set/getaffinity to modules
Date: Fri, 02 Jul 2010 11:01:43 -0700
Message-ID: <4C2E2987.9040702@us.ibm.com>
References: <1277983179.1917.10.camel@laptop> <1277984603.1917.15.camel@laptop> <20100701115507.GA31333@redhat.com> <20100701122340.GB31333@redhat.com> <1277987657.1917.32.camel@laptop> <1277988395.1917.47.camel@laptop> <20100701130816.GB32223@redhat.com> <1277991024.1917.108.camel@laptop> <20100701133956.GD32223@redhat.com> <4C2CA5C5.4040402@kernel.org> <20100701144624.GA11171@redhat.com> <4C2CABF2.2020801@kernel.org> <1277996135.1917.198.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitri Vorobiev <dmitri.vorobiev@movial.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andi Kleen <ak@linux.intel.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:47955 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757475Ab0GBSCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 14:02:19 -0400
In-Reply-To: <1277996135.1917.198.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2010 7:55 AM, Peter Zijlstra wrote:
> On Thu, 2010-07-01 at 16:53 +0200, Tejun Heo wrote:
>    
>> Hello,
>>
>> On 07/01/2010 04:46 PM, Oleg Nesterov wrote:
>>      
>>>> It might be a good idea to make the function take extra clone flags
>>>> but anyways once created cloned task can be treated the same way as
>>>> other kthreads, so nothing else needs to be changed.
>>>>          
>>> This makes kthread_stop() work. Otherwise the new thread is just
>>> the CLONE_VM child of the caller, and the caller is the user-mode
>>> task doing ioctl() ?
>>>        
>> Hmmm, indeed.  It makes the attribute inheritance work but circumvents
>> the whole reason there is kthreadd.
>>      
> I thought the whole reason there was threadd was to avoid the
> inheritance? So avoiding the avoiding of inheritance seems like the goal
> here, no?
>    
I think so. Does  it (Tejun's kthread_clone() patch) also  inherit the 
cgroup of the caller? or do we still need the explicit
call to attach the thread to the current task's cgroup?

I am on vacation next week and cannot look into this until Jul 12. Hope 
this will be resoved by then.
If not, i will look into after i am back.

Thanks
Sridhar

