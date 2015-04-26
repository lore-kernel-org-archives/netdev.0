From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Sun, 26 Apr 2015 13:35:12 +0300
Message-ID: <553CBF60.2070506@cloudius-systems.com>
References: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com> <20150324154732.57d84cb6@urahara> <552BA2A1.7020706@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38105 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbbDZKfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 06:35:17 -0400
Received: by wiun10 with SMTP id n10so61526608wiu.1
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2015 03:35:15 -0700 (PDT)
In-Reply-To: <552BA2A1.7020706@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/13/15 14:04, Vlad Zolotarov wrote:
>
>
> On 03/25/15 00:47, Stephen Hemminger wrote:
>> On Sun, 22 Mar 2015 20:52:58 +0200
>> Vlad Zolotarov <vladz@cloudius-systems.com> wrote:
>>
>>> Add a new option to toggle the ability of querying the RSS 
>>> configuration of a specific VF.
>>>
>>> VF RSS information like RSS hash key may be considered sensitive on 
>>> some devices where
>>> this information is shared between VF and PF and thus its querying 
>>> may be prohibited by default.
>>>
>>> This new option allows a system administrator with privileges to 
>>> modify a PF state
>>> to control if the above VF querying is allowed or not.
>>>
>>> For example:
>>>   To enable RSS querying of VF[0] of ethX:
>>>   >> ip link set dev ethX vf 0 query_rss on
>>>
>>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>> Holding off on this going into iproute until kernel component goes
>> into net-next
>
> Hi. The kernel patches have been pulled by Dave. Could u, pls., 
> proceed with this one?

ping ;)

>
> thanks,
> vlad
>
>>
>
