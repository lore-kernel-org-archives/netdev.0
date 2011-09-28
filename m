From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Date: Wed, 28 Sep 2011 07:59:31 +0530
Message-ID: <CAKTCnzm_BVOLK8c0rwYoDJCs+-920DWjwHFoQtgriRTEXrGiqw@mail.gmail.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-7-git-send-email-glommer@parallels.com>
	<m24o01khcp.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org,
	paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com,
	ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com,
	netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name
To: Andi Kleen <andi@firstfloor.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <m24o01khcp.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 24, 2011 at 10:28 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Glauber Costa <glommer@parallels.com> writes:
>
>> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
>> effectively control the amount of kernel memory pinned by a cgroup.
>>
>> We have to make sure that none of the memory pressure thresholds
>> specified in the namespace are bigger than the current cgroup.
>
> I noticed that some other OS known by bash seem to have a rlimit per
> process for this. Would that make sense too? Not sure how difficult
> your infrastructure would be to extend to that.

rlimit per process for tcp usage? Interesting, that reminds me, we
need to revisit rlimit (RSS) at some point

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
