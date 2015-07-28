From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next] bridge: mdb: add support for router
 add/del notifications monitoring
Date: Tue, 28 Jul 2015 13:15:14 +0200
Message-ID: <55B76442.9040005@cumulusnetworks.com>
References: <1437997445-29541-1-git-send-email-razor@blackwall.org>
 <20150727144018.1ffb2119@urahara>
 <13F15030-8AF3-4018-94B0-F2FF43A4E173@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Nikolay Aleksandrov <razor@blackwall.org>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37282 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbG1LPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 07:15:17 -0400
Received: by wibud3 with SMTP id ud3so154330940wib.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 04:15:16 -0700 (PDT)
In-Reply-To: <13F15030-8AF3-4018-94B0-F2FF43A4E173@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/27/2015 11:49 PM, Nikolay Aleksandrov wrote:
> 
>> On 27 Jul 2015, at 23:40, Stephen Hemminger <stephen@networkplumber.org> wrote:
>>
>> On Mon, 27 Jul 2015 13:44:05 +0200
>> Nikolay Aleksandrov <razor@blackwall.org> wrote:
>>
>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>>> This patch adds support for ADDMDB/DELMDB notifications about router ports
>>> which have been added or deleted/expired respectively.
>>>
>>> Example output:
>>> $ bridge -s monitor mdb
>>> Deleted router port dev eth3 master br0
>>> router port dev eth3 master br0
>>>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>> Looks useful, applied.
>>
>> Does usage or manual page need to be updated as well?
>>
>>
> 
> Good question :-) I'll look into it.
> Thanks!
> 

I've looked into it and we don't need any documentation/man changes
the mdb monitoring command is the same and the description doesn't specify
what exactly is being returned, so we're good.

Cheers,
 Nik
