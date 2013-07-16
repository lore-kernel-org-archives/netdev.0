From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [PATCH BUGFIX] pkt_sched: sch_qfq: remove a source of high packet
 delay/jitter
Date: Tue, 16 Jul 2013 08:46:41 +0200
Message-ID: <51E4EC51.6000607@unimore.it>
References: <1373911290-6237-1-git-send-email-paolo.valente@unimore.it> <1373911942.2062.24.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fchecconi@gmail.com, rizzo@iet.unipi.it
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373911942.2062.24.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 15/07/2013 20:12, Joe Perches ha scritto:
> On Mon, 2013-07-15 at 20:01 +0200, Paolo Valente wrote:
>> QFQ+ inherits from QFQ a design choice that may cause a high packet
>> delay/jitter and a severe short-term unfairness.
> []
>> diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> []
>> @@ -189,6 +188,7 @@ struct qfq_sched {
>>   	struct qfq_aggregate	*in_serv_agg;   /* Aggregate being served. */
>>   	u32			num_active_agg; /* Num. of active aggregates */
>>   	u32			wsum;		/* weight sum */
>> +	unsigned long		iwsum;		/* inverse weight sum*/
>
> This is a different size for 32/64 bit compiles
> and may be better as u32.
>
>
Sending a new version with u32, thanks.
