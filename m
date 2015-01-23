From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] iproute2: bridge: support vlan range
Date: Fri, 23 Jan 2015 07:42:44 -0800
Message-ID: <54C26BF4.3070305@cumulusnetworks.com>
References: <1421994310-48811-1-git-send-email-roopa@cumulusnetworks.com> <20150122225106.569d4b92@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, vyasevic@redhat.com,
	wkok@cumulusnetworks.com, sfeldma@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61505 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbAWPmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:42:45 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so4707693pab.5
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:42:45 -0800 (PST)
In-Reply-To: <20150122225106.569d4b92@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/15, 10:51 PM, Stephen Hemminger wrote:
> On Thu, 22 Jan 2015 22:25:10 -0800
> roopa@cumulusnetworks.com wrote:
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch adds vlan range support to bridge command
>> using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
>> BRIDGE_VLAN_INFO_RANGE_END.
>>
>> $bridge vlan show
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>
>> $bridge vlan add vid 10-15 dev dummy0
>> port    vlan ids
>> br0      1 PVID Egress Untagged
>>
>> dummy0   1 PVID Egress Untagged
>>           10
>>           11
>>           12
>>           13
>>           14
>>           15
> Doing on vlan id per line gets ridiculous with 1000 vlan's
> how about something more compact?
yes, I was going to do that in a separate patch ...the kernel can dump 
in ranges with the new flag.
I did not want to change default (current) show to print ranges.
Was planning on submitting a new patch with a new option. If you think 
there are not many users out there today..
..and no fear of breaking users, i will include it in the current patch 
in v3.

thanks.
