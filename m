From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 14:55:03 +0100
Message-ID: <efbda38a-2146-06b2-9151-19294c654d28@synopsys.com>
References: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
 <20170412115643.GA32596@lunn.ch>
 <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
 <20170412131008.GC32596@lunn.ch>
 <37cc8294-5514-ed02-9b41-86f8cc9c20ad@synopsys.com>
 <20170412135239.GD32596@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:39897 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdDLN4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 09:56:30 -0400
In-Reply-To: <20170412135239.GD32596@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Às 2:52 PM de 4/12/2017, Andrew Lunn escreveu:
>>>> My setup is FPGA based, so it will have lower performance values.
>>>> Iperf results with
>>>>   "Drop Transmit Status" set: ~650Mbps.
>>>>   "Drop Transmit Status" unset: ~450Mbps.
>>>
>>> What percentage of your customers use FPGAs? When i look at the users
>>> of this driver, i see ST, Allwinner, Rockchip, Meson, etc. So silicon,
>>> not FPGA. Does it make sense to do performance measurements on FPGA,
>>> when you say it has lower performance?
>>
>> I don't understand your question. Synopsys is an IP vendor, so all recent IPs
>> are available for prototyping as you can understand and so early development is
>> done using a FPGA.
> 
> Sure, early development on FPGA makes sense. But my guess is, > 95% of
> the devices running this driver are silicon, not FPGA. The customers
> you sell the IP to want to know that the driver is going to work well
> on their silicon, not your internal FPGA development setup. The kernel
> community want a warm fuzzy feeling that you care about the real
> devices out in the wild using this driver. So if you could say, "I
> tested on a STM DISCO devel board, and performance went up 20%, an
> RK3288 devel board and got 18% performance boost, and a Merrii A80
> Optimus Board showed 22% improvements", we would have a lot better
> feeling about these patches.

Understand your point, but for now our development and testing setup will be
based on the IP Prototyping Kit, consisting of a FPGA + PHY.

Thanks,
Joao

> 
> 	Andrew
> 
