From: Ben Greear <greearb@candelatech.com>
Subject: Re: under-performing bonded interfaces
Date: Wed, 21 Dec 2011 19:31:06 -0800
Message-ID: <4EF2A47A.3010006@candelatech.com>
References: <CANj2EbeMRzicixHwrKpCQ3mMqQ1qbyjbRCxpW+CmVRREAhyeRQ@mail.gmail.com> <4EC44ECB.4050201@candelatech.com> <CANj2EbfrtbysEbj+gMa+fOhWo0EWjBXVyGkw8WyiPAV9nPduuQ@mail.gmail.com> <1321491449.2709.90.camel@bwh-desktop> <CANj2Ebdd89=Fk6i4e4Txsb3ANuzz-x4t+tT6CAnWDNZe0zvx9g@mail.gmail.com> <1321498314.2885.78.camel@deadeye> <CANj2Eben0hrP6KwxyA1WPqiqzm84w=J2_sdtrKtGvxdftuksqg@mail.gmail.com> <20111221173608.0f04bc8b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Chen <simonchennj@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34882 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752872Ab1LVDbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 22:31:18 -0500
In-Reply-To: <20111221173608.0f04bc8b@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 05:36 PM, Stephen Hemminger wrote:
> On Wed, 21 Dec 2011 20:26:04 -0500
> Simon Chen<simonchennj@gmail.com>  wrote:
>
>> Hi folks,
>>
>> I added an Intel X520 card to both the sender and receiver... Now I
>> have two 10G ports on a PCIe 2.0 x8 slot (5Gx8), so the bandwidth of
>> the PCI bus shouldn't be the bottleneck.
>>
>> Now the throughput test gives me around 16Gbps in aggregate. Any ideas
>> how I can push closer to 20G? I don't quite understand where the
>> bottleneck is now.
>
> In my experience, Intel dual port cards can not run at full speed
> when both ports are in use. You need separate slots to hit full
> line rate.

We can run 2 ports right at 10Gbps tx + rx using a core-i7 980x
processor and 5gt/s pci-e bus.  This is using a modified version of
pktgen to generate traffic.  We can only push around 6 Gbps tx + rx
when generating tcp traffic to/from user-space, but our tcp generator
is not as optimized for bulk transfer as it could be.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
