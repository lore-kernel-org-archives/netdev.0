From: Ben Greear <greearb@candelatech.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 16 Nov 2011 16:07:46 -0800
Message-ID: <4EC45052.10101@candelatech.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com> <4EC44ECB.4050201@candelatech.com> <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59934 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab1KQAHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 19:07:52 -0500
In-Reply-To: <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/16/2011 04:05 PM, Simon Chen wrote:
> If used independently, I can get around 9.8Gbps.

On each of them concurrently, or just one at a time?

> [   11.572857] ixgbe 0000:03:00.0: Multiqueue Enabled: Rx Queue count
> = 24, Tx Queue count = 24
> [   11.572861] ixgbe 0000:03:00.0: (PCI Express:5.0Gb/s:Width x4)
> e8:9a:8f:23:42:1a
> [   11.572943] ixgbe 0000:03:00.0: MAC: 2, PHY: 8, SFP+: 3, PBA No: FFFFFF-0FF
> [   11.572944] ixgbe 0000:03:00.0: PCI-Express bandwidth available for
> this card is not sufficient for optimal performance.
> [   11.572946] ixgbe 0000:03:00.0: For optimal performance a x8
> PCI-Express slot is required.

Looks to me like it may be hardware related unless you are certain you
can get both NICs running at high-speed independently of any bonding
code...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
