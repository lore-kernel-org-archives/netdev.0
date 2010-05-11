From: Ben Greear <greearb@candelatech.com>
Subject: Re: get beyond 1Gbps with pktgen  on 10Gb nic?
Date: Tue, 11 May 2010 08:55:03 -0700
Message-ID: <4BE97DD7.7000704@candelatech.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net> <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Zhou <Jon.Zhou@jdsu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:46427 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304Ab0EKPzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 11:55:09 -0400
In-Reply-To: <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2010 06:35 AM, Ben Hutchings wrote:
> On Tue, 2010-05-11 at 06:13 -0700, Jon Zhou wrote:
>> hi there:
>>
>> anyone can get beyond 1Gbps with pktgen or other SW traffic generator with 10Gb nic(intel 82599 or BCM 57711)?
>> found that some one had met similar situation with broadcom 10G nic but no solution yet
>
> I don't know about those specific controllers, but you should be able to
> achieve close to 10G line rate with netperf's TCP_STREAM on any recent
> PC server.  UDP throughput tends to be poorer as there is less support
> for offloading segmentation and reassembly.  Performance may also be
> constrained by PCI Express bandwidth (you need a real 8-lane slot) and
> memory bandwidth (a single memory bank may not be enough).

We can easily push right at 10Gbps full-duplex on two ports (sending to self)
with a 2-port 82599 NIC, 3.3Ghz quad-core Intel core i7 6GT/s processor, etc.

In fact, recent testing with a 2-port 10G NIC and a bunch of intel 1G ports showed about
50Gbps aggregate bandwidth across the network on such a system.   (We were using 9000 MTU
for the 50Gbps test, but can reach 10G send-to-self with 1500 MTU on the 10G ports by themselves.)

This is all using a slightly modified pktgen, but normal pktgen should do just fine.

Thanks,
Ben

>
> Ben.
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
