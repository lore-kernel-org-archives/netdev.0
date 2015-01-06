From: Greg Rose <gvrose8192@gmail.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 6 Jan 2015 13:13:51 -0800
Message-ID: <CALgkqUoKBs8+Pney+nrFPTzE2bQaY+djkd3sFMfGs6dUZWannw@mail.gmail.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
	<CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
	<20150106065535.GM29889@cloudius-systems.com>
	<54ABBFEB.9010105@cloudius-systems.com>
	<CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
	<54AC1BBA.3010206@cloudius-systems.com>
	<CALgkqUr2tAprqmPVSwA3up9CtkPzgrci-0H05divHhT2NC5_kA@mail.gmail.com>
	<54AC4206.4030006@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Gleb Natapov <gleb@cloudius-systems.com>, netdev@vger.kernel.org,
	Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:38201 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbbAFVNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 16:13:52 -0500
Received: by mail-ob0-f175.google.com with SMTP id wp4so178743obc.6
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 13:13:51 -0800 (PST)
In-Reply-To: <54AC4206.4030006@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 6, 2015 at 12:13 PM, Vlad Zolotarov
<vladz@cloudius-systems.com> wrote:
>
> On 01/06/15 20:22, Greg Rose wrote:
>>

[snip]

>> I have not reached any such conclusion - let me reiterate:  I have no
>> idea.  It is not my area of expertise.  However, to take the lowest
>> risk route just add a policy hook so that a system admin can turn the
>> feature on through the PF driver (which is acknowledged as secure) if
>> they wish then there is no worry.
>
>
> NP. Let's move on.
>
>>> However I don't want to argue about any longer. Let's move on.
>>>
>>> Let's clarify one thing about this "hook". Do u agree that it should
>>> cover
>>> only the cases when VF shares the mentioned above data with PF - namely
>>> for
>>> all devices but x550?
>>
>> Look at how spoof checking is turned off/on for each VF using the "ip
>> link set" commands.  That's what I'm envisioning - some way to decide
>> on a per VF basis which VFs should be allowed to perform the query.
>
>
> I will but let's agree that x550 VFs should be out of this since their RSS
> indirection table and Key belong to the specific domain and don't impose any
> even theoretical thread.

Sounds good to me.

Thanks!

- Greg

>
>
> thanks,
> vlad
>
>> Thanks,
>>
>> - Greg
>
>
