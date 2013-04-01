From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  net-sysfs: make flags symmetrical
Date: Mon, 01 Apr 2013 15:26:06 -0700
Message-ID: <515A097E.60600@candelatech.com>
References: <20130401115315.1f8e4213@nehalam.linuxnetplumber.net> <5159EB2B.7070504@candelatech.com> <20130401150407.0d689980@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42643 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591Ab3DAW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 18:26:08 -0400
In-Reply-To: <20130401150407.0d689980@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2013 03:04 PM, Stephen Hemminger wrote:
> On Mon, 01 Apr 2013 13:16:43 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>
>> On 04/01/2013 11:53 AM, Stephen Hemminger wrote:
>>> The flags reported by sysfs are the raw kernel flags, not the version
>>> exported to user space. This leads to the unsymmetrical behaviour that
>>> read != write. An example of this is when a device is part of a
>>> bridge.  The PROMISC flag returned from sysfs will not be the same as
>>> other API's.
>>>
>>> The reason this patch deserves wider discussion is someone might be
>>> depending on sysfs to read raw kernel flags.
>>
>> I am depending on this feature.  There is no other way I know
>> of to determine if an interface is actually currently acting
>> PROMISC or not.
>>
>> Please don't 'fix' this.
>>
>> Thanks,
>> Ben
>>
>
> The real problem is there isn't a netlink attribute that encodes
> the real flags (there should be), and when device changes state a notification
> should be sent.

Ok, that sounds great to me...but plz don't remove the work-around
in sysfs in the meantime :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
