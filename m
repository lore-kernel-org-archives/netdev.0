From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Mon, 13 Apr 2015 14:04:01 +0300
Message-ID: <552BA2A1.7020706@cloudius-systems.com>
References: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com> <20150324154732.57d84cb6@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:32953 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357AbbDMLEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 07:04:05 -0400
Received: by wgin8 with SMTP id n8so76471196wgi.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 04:04:04 -0700 (PDT)
In-Reply-To: <20150324154732.57d84cb6@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/25/15 00:47, Stephen Hemminger wrote:
> On Sun, 22 Mar 2015 20:52:58 +0200
> Vlad Zolotarov <vladz@cloudius-systems.com> wrote:
>
>> Add a new option to toggle the ability of querying the RSS configuration of a specific VF.
>>
>> VF RSS information like RSS hash key may be considered sensitive on some devices where
>> this information is shared between VF and PF and thus its querying may be prohibited by default.
>>
>> This new option allows a system administrator with privileges to modify a PF state
>> to control if the above VF querying is allowed or not.
>>
>> For example:
>>   To enable RSS querying of VF[0] of ethX:
>>   >> ip link set dev ethX vf 0 query_rss on
>>
>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> Holding off on this going into iproute until kernel component goes
> into net-next

Hi. The kernel patches have been pulled by Dave. Could u, pls., proceed 
with this one?

thanks,
vlad

>
