From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [PATCH] pkt_sched: QFQ Plus: fair-queueing service at DRR cost
Date: Tue, 20 Nov 2012 18:45:02 +0100
Message-ID: <50ABC19E.9030209@unimore.it>
References: <20121112164833.GA12970@paolo-ThinkPad-W520> <20121119.184828.628106002307042971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, shemminger@vyatta.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rizzo@iet.unipi.it, fchecconi@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121119.184828.628106002307042971.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Il 20/11/2012 00:48, David Miller ha scritto:
> From: Paolo Valente <paolo.valente@unimore.it>
> Date: Mon, 12 Nov 2012 17:48:33 +0100
>
>> [This patch received positive feedback from Stephen Hemminger ("put =
in
>> net-next"), but no further feedback or decision. So I am (re)sending
>> an updated version of it. The only differences with respect to the
>> previous version are the support for TSO/GSO (taken from QFQ), and a
>> hopefully improved description.]
>
> Can you rearrange the logic so that the compiler doesn't emit this
> warning?
>
> In file included from net/sched/sch_qfq.c:18:0:
> net/sched/sch_qfq.c: In function =A1qfq_dequeue=A2:
> include/net/sch_generic.h:480:15: warning: =A1skb=A2 may be used unin=
itialized in this function [-Wmaybe-uninitialized]
> net/sched/sch_qfq.c:1007:18: note: =A1skb=A2 was declared here
>
> You and I both know that SKB will be initialized at this point, but
> the compiler can't see it clearly enough.
>
Unfortunately I could not reproduce the warning (with
gcc-4.7 -Wmaybe-uninitialized). I am however about to send a new versio=
n=20
with skb initialized to NULL. I hope that this fix properly addresses=20
this issue.
> Thanks.
>


--=20
-----------------------------------------------------------
| Paolo Valente              |                            |
| Algogroup                  |                            |
| Dip. Ing. Informazione     | tel:   +39 059 2056318     |
| Via Vignolese 905/b        | fax:   +39 059 2056129     |
| 41125 Modena - Italy       |                            |
|     home:  http://algo.ing.unimo.it/people/paolo/       |
-----------------------------------------------------------
