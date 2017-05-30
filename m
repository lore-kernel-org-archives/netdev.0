From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH V6 net-next iproute] ip: Add support for netdev events to
 monitor
Date: Tue, 30 May 2017 14:26:04 -0400
Message-ID: <65cf9b5f-2d71-34dc-483d-ecb91d93626a@redhat.com>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
 <1495894476-9726-4-git-send-email-vyasevic@redhat.com>
 <20170530101221.1c5cb643@xeon-e3>
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
Received: from mx1.redhat.com ([209.132.183.28]:36686 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750761AbdE3S0H (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 14:26:07 -0400
In-Reply-To: <20170530101221.1c5cb643@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/2017 01:12 PM, Stephen Hemminger wrote:
> On Sat, 27 May 2017 10:14:36 -0400
> Vladislav Yasevich <vyasevich@gmail.com> wrote:
> 
>>  
>> +static const char *netdev_events[] = {"NONE",
>> +				      "REBOOT",
>> +				      "FEATURE CHANGE",
>> +				      "BONDING FAILOVER",
>> +				      "NOTIFY PEERS",
>> +				      "RESEND IGMP",
>> +				      "BONDING OPTION"};
> 
> Overall this looks fine, I will pickup the if_link.h from net-next.
> 
> One stylistic change.
> 
> Please add simple line break, and initialize by value:
> 
> static const char *netdev_events[] = {
> 	[IFLA_EVENT_NONE]	= "NONE",
> ...
> 
> Do you want some prefix or bounding around the event output?

Don't really care about output from my side.  If you think some prefix
would be good, I can surely add it.

> Also a little concerned that the output format change may break some program
> could the new output be at the end of the line?
> 

I can try moving it to the end.

Thanks
-vlad
