From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Mon, 23 Mar 2015 12:46:12 +0200
Message-ID: <550FEEF4.4060702@cloudius-systems.com>
References: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com> <1427107361.2577.173.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:36336 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751935AbbCWKqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 06:46:16 -0400
Received: by wibg7 with SMTP id g7so43545674wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 03:46:14 -0700 (PDT)
In-Reply-To: <1427107361.2577.173.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/23/15 12:42, Jeff Kirsher wrote:
> On Sun, 2015-03-22 at 20:52 +0200, Vlad Zolotarov wrote:
>> Add a new option to toggle the ability of querying the RSS
>> configuration of a specific VF.
>>
>> VF RSS information like RSS hash key may be considered sensitive on
>> some devices where
>> this information is shared between VF and PF and thus its querying may
>> be prohibited by default.
>>
>> This new option allows a system administrator with privileges to
>> modify a PF state
>> to control if the above VF querying is allowed or not.
>>
>> For example:
>>   To enable RSS querying of VF[0] of ethX:
>>   >> ip link set dev ethX vf 0 query_rss on
>>
>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>> ---
>>   include/linux/if_link.h |  8 ++++++++
>>   ip/iplink.c             | 13 +++++++++++++
>>   2 files changed, 21 insertions(+)
> I have added your other patch series to my next-queue tree for further
> review and testing.  I have also made validation aware of this patch to
> properly review your changes, thanks Vlad.

Great! Thanks, Jeff.
