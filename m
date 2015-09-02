From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Support ip route get via given table
Date: Wed, 2 Sep 2015 13:50:27 -0600
Message-ID: <55E75303.208@cumulusnetworks.com>
References: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
 <20150902191244.GE20527@pox.localdomain>
 <55E74C78.8000409@cumulusnetworks.com>
 <20150902193838.GA25648@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35118 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbIBTua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 15:50:30 -0400
Received: by ioiz6 with SMTP id z6so33205498ioi.2
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 12:50:29 -0700 (PDT)
In-Reply-To: <20150902193838.GA25648@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/15 1:38 PM, Thomas Graf wrote:
> On 09/02/15 at 01:22pm, David Ahern wrote:
>> On 9/2/15 1:12 PM, Thomas Graf wrote:
>>> On 09/02/15 at 12:03pm, David Ahern wrote:
>>>> Add support for 'ip [-6] route get table X' where the user wants to
>>>> force the FIB lookup from a given table.
>>>>
>>>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>>>
>>> Will you use this outside of 'ip route get' as well? If so, how? I'm
>>> asking because you propose to add the check and new behaviour to bypass
>>> the routing rules to the routing fastpath, wouldn't it be better to
>>> handle this in inet_rtm_getroute()?
>>>
>>
>> The way IPv6 code is structured it seemed more appropriate to pass in a
>> table id as part of the flow. I made IPv4 consistent with that approach.
>
> The question is: Are you planning to use the new table_id in flowi
> in the actual datapath as well? It seems entirely wrong to add
> weight to the fast path for a control plane feature.
>

No plans at the moment.
