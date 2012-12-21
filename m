From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Fri, 21 Dec 2012 15:35:22 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com>
 <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com>
 <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>
 <50D46060.2070308@gmail.com> <50D46928.9070809@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D46928.9070809@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2012-12-21 14:50, Jamal Hadi Salim wrote:
> On 12-12-21 08:13 AM, Yury Stankevich wrote:

>> i use it ingress,
>> so, i need to use tc xt action
>> to get mark on the packet, before filter on ifb will run.
>> prerouting rule, in turn, used to test if mark was actually restored.
>
> No experience with connmark, but - in order to restore something has
> to store it, correct?

The bigger problem here, if I see __netif_receive_skb right, is that
when ingress rules run, skb->nfct is still unset, thereby the
CONNMARK action is a no-op.
