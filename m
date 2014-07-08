From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: mm/sched/net: BUG when running simple code
Date: Tue, 08 Jul 2014 11:25:49 -0400
Message-ID: <53BC0D7D.9000207@oracle.com>
References: <539A6850.4090408@oracle.com> <20140708145147.GH6758@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Dave Jones <davej@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20140708145147.GH6758@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 07/08/2014 10:51 AM, Peter Zijlstra wrote:
> On Thu, Jun 12, 2014 at 10:56:16PM -0400, Sasha Levin wrote:
>> Hi all,
>> 
>> Okay, I'm really lost. I got the following when fuzzing, and can't really explain what's going on. It seems that we get a "unable to handle kernel paging request" when running rather simple code, and I can't figure out how it would cause it.
>> 
> 
> Are you running on AMD hardware? If so; check out this thread:
> 
> http://marc.info/?i=53B02CEB.7010607@web.de
> 

Unfortunately (luckily?) it's all Intel over here.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
