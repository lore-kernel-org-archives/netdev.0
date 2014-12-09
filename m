From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] fix suspicious rcu_dereference_check in net/sched/sch_fq_codel.c
Date: Tue, 09 Dec 2014 15:13:16 -0800
Message-ID: <5487820C.4030801@intel.com>
References: <58905.1418159750@turing-police.cc.vt.edu> <1418161372.27198.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1418161372.27198.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/09/2014 01:42 PM, Eric Dumazet wrote:
> On Tue, 2014-12-09 at 16:15 -0500, Valdis Kletnieks wrote:
>> commit 46e5da40ae (net: qdisc: use rcu prefix and silence
>>  sparse warnings) triggers a spurious warning:
>>
>> net/sched/sch_fq_codel.c:97 suspicious rcu_dereference_check() usage!
>>
>> The code should be using the _bh variant of rcu_dereference.
>>
>> Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>
>> ---
>>  net/sched/sch_fq_codel.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Thanks !
> 
> 

Great thanks for finding/fixing!

Acked-by: John Fastabend <john.r.fastabend@intel.com>
