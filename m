From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: Re: [PATCH] e1000e:  MSI interrupt test failed, using legacy interrupt
Date: Thu, 26 Apr 2012 17:42:19 -0700
Message-ID: <4F99EB6B.7090000@riverbed.com>
References: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com> <4F99E653.4000608@gmail.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <tarbal@gmail.com>, prasanna.panchamukhi@riverbed.com,
	bruce.w.allan@intel.com, jeffrey.e.pieper@intel.com,
	bhutchings@solarflare.com, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([208.70.196.44]:29139 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab2D0AmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 20:42:21 -0400
In-Reply-To: <4F99E653.4000608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2012 05:20 PM, Jeff Kirsher wrote:
> On 04/26/2012 05:05 PM, prasanna.panchamukhi@riverbed.com wrote:
>> From: Prasanna S. Panchamukhi<ppanchamukhi@riverbed.com>
>>
>> Following logs where seen on Systems with multiple NICs&  ports,
>> while using MSI interrupts as shown below:
>>
>> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0d.0: lan0_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: wan0_1: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: lan0_1: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:32 (none) user.warn kernel: 0000:40:0e.0: wan4_0: MSI interrupt
>> test failed, using legacy interrupt.
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0e.0: wan1_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0e.0: lan1_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: wan2_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: lan2_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: wan3_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: lan3_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0e.0: lan4_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: wan5_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: lan5_0: NIC Link is Up
>> 1000 Mbps Full Duplex, Flow Control: RX/TX
>>
>> This patch changes the IRQ tests to use polling loops starting with a
>> delay of 1 tick and doubling that if necessary up to a maximum total
>> delay of approximately 1 second.
>>
>> Signed-off-by: Prasanna S. Panchamukhi<ppanchamukhi@riverbed.com>
>> ---
>>   drivers/net/ethernet/intel/e1000e/netdev.c |   27 +++++++++++++++++++++++----
>>   1 files changed, 23 insertions(+), 4 deletions(-)
> Thanks Prasanna, Dave did accept the previous patch, so does this patch
> take that into account?
No, If Dave has already accepted previous patch we can ignore this patch 
for now.

Thanks,
Prasanna
>
>
