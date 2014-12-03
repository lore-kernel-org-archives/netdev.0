From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next] r8152: reduce memory copy for rx
Date: Wed, 3 Dec 2014 07:05:10 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ED360A@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-105-Taiwan-albertk@realtek.com>
 <1417586858.5303.118.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417586858.5303.118.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet [mailto:eric.dumazet@gmail.com] 
> Sent: Wednesday, December 03, 2014 2:08 PM
[...]
> Better performance for what workload exactly ?

I test it by using Chariot with 4 Tx and 4 Rx.
It has about 4% improvement.

> cloning in rx path has many drawbacks, with skb->truesize 
> being usually wrong.

Excuse me. I find the skb_clone() would copy the
truesize from original skb. Do you mean the value
may not be suitable for the cloned skb?

Could other method do the same thing? Or, do you
think keeping the original one is better?
 
Best Regards,
Hayes
