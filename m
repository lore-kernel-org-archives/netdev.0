From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [Patch v3 net-next 09/12] net: fec: change FEC alignment
 according to i.mx6 sx requirement
Date: Fri, 12 Sep 2014 15:45:01 -0500
Message-ID: <CAHrpEqTV=5phAOkOMLoi2kzxNpBAp5g=pVDj9G8CkUmHp9dTwQ@mail.gmail.com>
References: <1410373845-5801-1-git-send-email-Frank.Li@freescale.com>
	<1410373845-5801-10-git-send-email-Frank.Li@freescale.com>
	<20140912.164047.810313458974612565.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Duan Fugang-B38611 <b38611@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@linaro.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:39588 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaILUpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:45:03 -0400
In-Reply-To: <20140912.164047.810313458974612565.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 3:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Frank Li <Frank.Li@freescale.com>
> Date: Thu, 11 Sep 2014 02:30:42 +0800
>
>> +
>> +     unsigned tx_align;
>> +     unsigned rx_align;
>>  };
>
> Please always fully write out "unsigned int" rather than just "unsigned".
>
>> @@ -2399,6 +2393,7 @@ fec_enet_alloc_rxq_buffers(struct net_device *ndev, unsigned int queue)
>>       struct sk_buff *skb;
>>       struct bufdesc  *bdp;
>>       struct fec_enet_priv_rx_q *rxq;
>> +     unsigned off;
>
> Likewise.

Okay, I will fix it next version.

best regards
Frank Li
