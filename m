From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Mon, 5 Dec 2016 15:43:48 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7DDD6F@lhreml503-mbx>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
        <20161130.142539.1927956259851457047.davem@davemloft.net>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A7D4439@lhreml503-mbx>
 <20161203.150905.739546865468666597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161203.150905.739546865468666597.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, December 03, 2016 8:09 PM
> To: Salil Mehta
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally convey
> RX checksum flag to stack
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Thu, 1 Dec 2016 12:09:22 +0000
> 
> > But maybe now since we don't have any method to de-multiplex the kind
> of
> > checksum error (cannot depend upon register) we can have below code
> > re-arrangement:
> >
> > hns_nic_rx_checksum() {
> >       /* check supported L3 protocol */
> > 	if (l3 != IPV4 && l3 != IPV6)
> > 		return;
> >       /* check if L3 protocols error */
> >       if (l3e)
> > 	 	return;
> >
> >       /* check if the packets are fragmented */
> > 	If (l3frags)
> > 		Return;
> >
> >       /* check supported L4 protocol */
> >  	if (l4 != UDP && l4 != TCP && l4 != SCTP)
> >  		return;
> >       /* check if any L4 protocol error */
> >       if (l3e)
> > 	 	return;
> >
> >       /* packet with valid checksum - covey to stack */
> >       skb->ip_summed = CHECKSUM_UNNECESSARY
> > }
> 
> This looks a lot cleaner and easier to understand.
Sure, floated Patch V3. Please have a look. Thanks!

Best regards
Salil
