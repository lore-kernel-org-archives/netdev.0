From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V6 net-next iproute] ip: Add support for netdev events to
 monitor
Date: Wed, 31 May 2017 16:27:03 -0400
Message-ID: <3b60a05e-0ae2-4fa6-d2bc-5e10e94cf16e@redhat.com>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
 <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
 <20170530101221.1c5cb643@xeon-e3>
 <65cf9b5f-2d71-34dc-483d-ecb91d93626a@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net
To: Stephen Hemminger <stephen@networkplumber.org>,
        Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35458 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750952AbdEaU1F (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 16:27:05 -0400
In-Reply-To: <65cf9b5f-2d71-34dc-483d-ecb91d93626a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 02:26 PM, Vlad Yasevich wrote:
> On 05/30/2017 01:12 PM, Stephen Hemminger wrote:
>> On Sat, 27 May 2017 10:14:36 -0400
>> Vladislav Yasevich <vyasevich@gmail.com> wrote:
>>
>>>  
>>> +static const char *netdev_events[] = {"NONE",
>>> +				      "REBOOT",
>>> +				      "FEATURE CHANGE",
>>> +				      "BONDING FAILOVER",
>>> +				      "NOTIFY PEERS",
>>> +				      "RESEND IGMP",
>>> +				      "BONDING OPTION"};
>>
>> Overall this looks fine, I will pickup the if_link.h from net-next.
>>
>> One stylistic change.
>>
>> Please add simple line break, and initialize by value:
>>
>> static const char *netdev_events[] = {
>> 	[IFLA_EVENT_NONE]	= "NONE",
>> ...
>>
>> Do you want some prefix or bounding around the event output?
> 
> Don't really care about output from my side.  If you think some prefix
> would be good, I can surely add it.
> 
>> Also a little concerned that the output format change may break some program
>> could the new output be at the end of the line?
>>
> 
> I can try moving it to the end.
>

Hi Stephen

So, I looked again at this patch and the output change I am proposing would look
something like this 'ip monitor':

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 6500 qdisc noqueue state UNKNOWN group default event
FEATURE CHANGE
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00


It's already at the end of the like ant has an 'event' prefix similar to all the other
entries on the top line.  Does that look OK?  I don't think that would break anything.

Thanks
-vlad
