From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 04/46] percpu_rwlock: Implement the core design of
 Per-CPU Reader-Writer Locks
Date: Sat, 02 Mar 2013 01:29:21 +0530
Message-ID: <51310899.1090308@linux.vnet.ibm.com>
References: <CACvQF53bdh4_BxF0y1fnTVR+T2OmRc0jmWQYftsvx92-fg-Lug@mail.gmail.com> <512BBAD8.8010006@linux.vnet.ibm.com> <CACvQF51jCxk5jUqmhD=QBBtUsBkQWZzakacrKO4Gsk=w61rNwQ@mail.gmail.com> <512C7A38.8060906@linux.vnet.ibm.com> <CACvQF51RvhM8XNqu3-1OTQ=cZUZ=pAX+_zx0a29+W67N1X+BgQ@mail.gmail.com> <512CC509.1050000@linux.vnet.ibm.com> <CACvQF50UgiqPpDk3HCmV86zKSf6tPjqr0bZowfPEOJs0g0r0MQ@mail.gmail.com> <512D0D67.9010609@linux.vnet.ibm.com> <CACvQF53ph2ixdM-otzetjM5cR+2kcZj6sckOp3TnzzA_x-EZ8w@mail.gmail.com> <512E7879.20109@linux.vnet.ibm.com> <20130301181054.GD2481@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lai Jiangshan <eag0628@gmail.com>,
	Michel Lespinasse <walken@google.com>,
	linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org,
	namhyung@kernel.org, mingo@kernel.org, linux-arch@vger.kernel.org,
	linux@arm.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com,
	wangyun@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	rusty@rustcorp.com.au, rostedt@goodmis.org, rjw@sisk.pl,
	vincent.guittot@linaro.org, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130301181054.GD2481@mtj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 03/01/2013 11:40 PM, Tejun Heo wrote:
> Hello, Srivatsa.
> 
> On Thu, Feb 28, 2013 at 02:49:53AM +0530, Srivatsa S. Bhat wrote:
>> Don't get me wrong - I'll whole-heartedly acknowledge and appreciate if
>> _your_ code is better than mine. I just don't like the idea of somebody
>> plagiarizing my ideas/code (or even others' ideas for that matter).
>> However, I sincerely apologize in advance if I misunderstood/misjudged your
>> intentions; I just wanted to voice my concerns out loud at this point,
>> considering the bad feeling I got by looking at your responses collectively.
> 
> Although I don't know Lai personally, from my experience working with
> him past several months on workqueue, I strongly doubt he has dark
> urterior intenions.  The biggest problem probably is that his
> communication in English isn't very fluent yet and thus doesn't carry
> the underlying intentions or tones very well and he tends to bombard
> patches in quick succession without much explanation inbetween (during
> 3.8 cycle, I was receiving several workqueue patchsets days apart
> trying to solve the same problem with completely different approaches
> way before the discussion on the previous postings reach any kind of
> consensus).  A lot of that also probably comes from communication
> problems.
> 
> Anyways, I really don't think he's trying to take claim of your work.
> At least for now, you kinda need to speculate what he's trying to do
> and then confirm that back to him, but once you get used to that part,
> he's pretty nice to work with and I'm sure his communication will
> improve in time (I think it has gotten a lot better than only some
> months ago).
>

Thank you so much for helping clear the air, Tejun! I'm truly sorry again
for having drawn the wrong conclusions based on gaps in our communication.
It was a mistake on my part and I would like to request Lai to kindly
forgive me. I'm looking forward to working with Lai effectively, going
forward.

Thank you!

Regards,
Srivatsa S. Bhat
