From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Sat, 22 Dec 2012 08:42:18 -0500
Message-ID: <50D5B8BA.9010808@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com>  <50CCE961.5050204@mojatatu.com>  <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr>  <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com>  <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com>  <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr>  <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com>  <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>  <50D06177.2090905@mojatatu.com>  <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com>  <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>  <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com>  <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com>  <50D46060.2070308@gmail.
 com> <50D46928.9070809@mojatatu.com>  <alpine.LNX.2.01.1212211533360.957@nerf07.vanv.qr> <1356104720.21834.7497.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1356104720.21834.7497.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-21 10:45 AM, Eric Dumazet wrote:
> On Fri, 2012-12-21 at 15:35 +0100, Jan Engelhardt wrote:
>

> This reminds me this might be the reason we have
> skb_reset_transport_header(skb);
> in __netif_receive_skb(), while its not very logical.
>

You seem to have nailed the egress part finally. That has
been a constant battle. At one point the standard answer
was "turn off TSO" ;->

> (Yes, sorry for being off topic, but I am referring to
> http://www.spinics.net/lists/netdev/msg214662.html )


I think the skb_reset_transport_header() when Acme made
a major overhaul to replace direct pointer access.
For this reason i think your second option seems preferable.

cheers,
jamal

