From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 2/5] bridge: Add vlan to unicast fdb entries
Date: Thu, 23 Aug 2012 15:42:23 -0400
Message-ID: <5036879F.60206@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <1345750195-31598-3-git-send-email-vyasevic@redhat.com> <20120823123901.08b7e13e@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756273Ab2HWTmY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:42:24 -0400
In-Reply-To: <20120823123901.08b7e13e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2012 03:39 PM, Stephen Hemminger wrote:
> On Thu, 23 Aug 2012 15:29:52 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
>> index dd3f201..288ff10 100644
>> --- a/include/linux/if_bridge.h
>> +++ b/include/linux/if_bridge.h
>> @@ -95,6 +95,7 @@ struct __fdb_entry {
>>   	__u8 port_hi;
>>   	__u8 pad0;
>>   	__u16 unused;
>> +#define fdb_vid unused
>
> That is seriously ugly. Just change the structure definition
> to use the value.

Ok.  I did that originally, but that made it hard to detect in 
userspace.  I'll think of something.

-vlad
