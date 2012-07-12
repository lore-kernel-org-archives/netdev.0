From: Nandita Dukkipati <nanditad@google.com>
Subject: Re: [PATCH v3 net-next] tcp: TCP Small Queues
Date: Wed, 11 Jul 2012 17:46:35 -0700
Message-ID: <CAB_+Fg5dwsNYkL+rQ4HsrDyHi-3w+EcLjWr0F=HbyLPyXT25AQ@mail.gmail.com>
References: <1342021831.3265.8174.camel@edumazet-glaptop>
	<CAB_+Fg496FgQZkJE8uf_4RX_wW+fz1p5Rq8rY=BuA=c6KPakpA@mail.gmail.com>
	<1342051233.3265.8206.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, codel@lists.bufferbloat.net, ncardwell@google.com,
	David Miller <davem@davemloft.net>, mattmathis@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <codel-bounces@lists.bufferbloat.net>
In-Reply-To: <1342051233.3265.8206.camel@edumazet-glaptop>
List-Unsubscribe: <https://lists.bufferbloat.net/options/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=unsubscribe>
List-Archive: <https://lists.bufferbloat.net/pipermail/codel>
List-Post: <mailto:codel@lists.bufferbloat.net>
List-Help: <mailto:codel-request@lists.bufferbloat.net?subject=help>
List-Subscribe: <https://lists.bufferbloat.net/listinfo/codel>,
	<mailto:codel-request@lists.bufferbloat.net?subject=subscribe>
Sender: codel-bounces@lists.bufferbloat.net
Errors-To: codel-bounces@lists.bufferbloat.net
List-Id: netdev.vger.kernel.org

>> Considering these two points, why TSQ over the Codel feedback
>> approach?
>
> I dont think they compete. They are in fact complementary.
>
> If you use codel/fq_codel + TSQ, you have both per flow limitation in
> qdisc (TSQ) + sojourn time aware and multi flow aware feedback.

Makes sense. My conjecture is when using codel/fq_codel qdisc, the
need for TSQ will diminish. But as you said... good part of TSQ is it
limits per-flow queuing for any qdisc structure, even those not using
codel.
