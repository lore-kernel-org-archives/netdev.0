From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 2/6] IP100A Fix Tx pause bug
Date: Tue, 22 Aug 2006 09:17:08 +0800
Message-ID: <00bd01c6c588$afdedbc0$4964a8c0@icplus.com.tw>
References: <1155841445.4532.10.camel@localhost.localdomain> <44E5A425.8020200@pobox.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr34.hinet.net ([168.95.4.134]:65449 "EHLO msr34.hinet.net")
	by vger.kernel.org with ESMTP id S932070AbWHVBUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 21:20:13 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message ----- 
From: "Jeff Garzik" <jgarzik@pobox.com>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<akpm@osdl.org>
Sent: Friday, August 18, 2006 7:27 PM
Subject: Re: [PATCH 2/6] IP100A Fix Tx pause bug

(1)
>> + iowrite8(127, ioaddr + TxDMAPollPeriod);
>> +
>
> what does the value 127 represent?

127 is polling period of Tx DMA to watch if there any packet need to send.
The 127 means 127*320ns.

(2)
> DownCounter should not be written unconditionally.  Consider shared
> interrupts, where sundance performs no work, and handled==0.

DownCount is a the register that we can use for timer interrupt. When the
value of  DownCount from 1 count down to 0 , IP100A will issue an interrupt.


