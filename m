From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS indirection
 table and key
Date: Tue, 06 Jan 2015 22:13:58 +0200
Message-ID: <54AC4206.4030006@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>	<CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>	<20150106065535.GM29889@cloudius-systems.com>	<54ABBFEB.9010105@cloudius-systems.com>	<CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>	<54AC1BBA.3010206@cloudius-systems.com> <CALgkqUr2tAprqmPVSwA3up9CtkPzgrci-0H05divHhT2NC5_kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gleb Natapov <gleb@cloudius-systems.com>, netdev@vger.kernel.org,
	Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:51917 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbbAFUOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 15:14:04 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so224633wiv.8
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 12:14:02 -0800 (PST)
In-Reply-To: <CALgkqUr2tAprqmPVSwA3up9CtkPzgrci-0H05divHhT2NC5_kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/06/15 20:22, Greg Rose wrote:
> I accidentally replied just to Vlad - here is a reply to all.
>
> On Tue, Jan 6, 2015 at 9:30 AM, Vlad Zolotarov
> <vladz@cloudius-systems.com>  wrote:
>> On 01/06/15 18:59, Greg Rose wrote:
> [snip]
>
>
>>> I don't have any examples and that is not my area of expertise.  But
>>> just because we can't think of a security risk or attack example
>>> doesn't mean there isn't one.
>>>
>>> Just add a policy hook so that the system admin can decide whether
>>> this information should be shared with the VFs and then we're covered
>>> for cases of both known and unknown exploits, risks, etc.
>> I absolutely disagree with u in regard of defining an RSS redirection table
>> and RSS hash key as a security sensitive data. I don't know how u got to
>> this conclusion.
> I have not reached any such conclusion - let me reiterate:  I have no
> idea.  It is not my area of expertise.  However, to take the lowest
> risk route just add a policy hook so that a system admin can turn the
> feature on through the PF driver (which is acknowledged as secure) if
> they wish then there is no worry.

NP. Let's move on.

>> However I don't want to argue about any longer. Let's move on.
>>
>> Let's clarify one thing about this "hook". Do u agree that it should cover
>> only the cases when VF shares the mentioned above data with PF - namely for
>> all devices but x550?
> Look at how spoof checking is turned off/on for each VF using the "ip
> link set" commands.  That's what I'm envisioning - some way to decide
> on a per VF basis which VFs should be allowed to perform the query.

I will but let's agree that x550 VFs should be out of this since their 
RSS indirection table and Key belong to the specific domain and don't 
impose any even theoretical thread.

thanks,
vlad

> Thanks,
>
> - Greg
