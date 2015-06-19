From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 0/3] light weight tunnel infrastructure
 and driver
Date: Fri, 19 Jun 2015 08:05:45 -0700
Message-ID: <55842FC9.8080400@cumulusnetworks.com>
References: <1434689355-4088-1-git-send-email-roopa@cumulusnetworks.com> <5584296C.1080108@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36265 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbFSPFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:05:48 -0400
Received: by paceq1 with SMTP id eq1so62484205pac.3
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 08:05:47 -0700 (PDT)
In-Reply-To: <5584296C.1080108@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 7:38 AM, Robert Shearman wrote:
>> This series implements infrastructure for light weight tunnels to 
>> support
>> mpls label edge routers (ie mpls ip tunnels). As previously discussed
>> having netdevices will not scale. Hence this series introduces new 
>> RTA_ENCAP*
>> attributes to attach encap information with routes (following suggestion
>> from Eric Biederman).
>
> Looks promising, thanks for posting this series Roopa!
>
>>
>> The first patch introduces an infrastructure to support light weight 
>> tunnels
>> that dont have netdevices. The infrastructure allows tunnel drivers
>> to register handlers to parse and build tunnel encap data which can 
>> be attached
>> to each route nexthop.
>>
>> The second patch adds support in ipv4 fib to carry such light weight 
>> tunnel
>> encap data.
>
> I presume this isn't ready to be merged until IPv6 is done, right?
yes, I will be adding ipv6 support soon. I will post the next non-RFC 
series with the ipv6 changes

thanks,
Roopa
