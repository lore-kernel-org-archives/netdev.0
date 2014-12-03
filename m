From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8152: reduce memory copy for rx
Date: Wed, 3 Dec 2014 09:09:12 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED364C@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-105-Taiwan-albertk@realtek.com>
	 <1417586858.5303.118.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0835B3720019904CB8F7AA43166CEEB2ED360A@RTITMBSV03.realtek.com.tw>
 <1417590925.5303.127.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417590925.5303.127.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet [mailto:eric.dumazet@gmail.com] 
> Sent: Wednesday, December 03, 2014 3:15 PM
[...]
> Have you tried using more concurrent RX flows, in a possibly lossy
> environment (so that TCP is forced to queue packets in out of order
> queue) ?

I don't do the test. I would check it next time.

> skb cloning prevents GRO and TCP coalescing from working.
> 
> netfilter might also be forced to copy whole frame in case a mangle is
> needed (eg with NAT ...)
> 
> I would rather try to implement GRO, and/or using fragments instead of
> pure linear skbs.
> 
> (skb->head would be around 128 or 256 bytes, and you attach to skb the
> frame as a page fragment)

Thanks for your response. I would study the GRO first.
 
Best Regards,
Hayes
