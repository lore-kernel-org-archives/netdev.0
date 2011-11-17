From: Ben Greear <greearb@candelatech.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 16:01:15 -0800
Message-ID: <4EC44ECB.4050201@candelatech.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51804 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab1KQABS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:01:18 -0500
In-Reply-To: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2011 03:44 PM, Simon Chen wrote:
> Hello,
>
> I am bonding two 10G interfaces (ixgbe driver) under Debian 6.0.2. The
> bonded interface for some reason can only achieve 12Gbps aggregated
> throughput. If a single NIC is used, I can get close to 10Gbps.
>
> I've tried different bonding modes (balance-xor, 802.3ad, balance-alb,
> balance-tlb), and different xmit hashing policy (layer2, layer2+3,
> layer3+4). I've increased all types of kernel parameters for TCP. MTU
> on the physical and bonded interface is set to 8000 and 9000. The MTU
> on the switch is 9200+.
>
> Instead of nperf (a single server), I also tried my own TCP sender and
> receivers.
>
> All those done, still only 12Gbps... How can I really achieve close to 20Gbps?
>
> (I also tried cutting loose the switch in between, and also getting
> 12G, so not an issue with the switch.)

How much can you get if you run each of the NIC ports independently
w/out bonding?  Plz send the 'dmesg' messages about ixgbe (ie, how
many lanes, how many GT/s).  What is your processor?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
