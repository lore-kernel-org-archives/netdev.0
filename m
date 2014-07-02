From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v3] 6lowpan: mac802154: fix
 coding style issues
Date: Tue, 1 Jul 2014 21:38:53 -0700
Message-ID: <CAGVrzcaCesZ29U5xth+B0YNKv4yQ=JuFVV+QyJ7MmFJ7jKTPgg@mail.gmail.com>
References: <1404271869-2316-1-git-send-email-varkab@cdac.in>
 <CAGVrzcYc9u2TAxhb8vPOevLYiZUsOyEcUAbxZ4aLrns3Vt97yw@mail.gmail.com> <53B38A6E.2000603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Varka Bhadram <varkab@cdac.in>,
	David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	Joe Perches <joe@perches.com>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:59782 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbaGBEje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:39:34 -0400
Received: by mail-oa0-f54.google.com with SMTP id eb12so11601446oac.41
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:39:34 -0700 (PDT)
In-Reply-To: <53B38A6E.2000603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-07-01 21:28 GMT-07:00 Varka Bhadram <varkabhadram@gmail.com>:
> Hi  Florian,
>
>
> On 07/02/2014 09:50 AM, Florian Fainelli wrote:
>>
>> Hi,
>>
>> 2014-07-01 20:31 GMT-07:00 Varka Bhadram <varkabhadram@gmail.com>:
>>>
>>> This patch fixed the coding style issues reported by checkpatch.pl
>>>
>>> following issues fixed:
>>>          CHECK: Alignment should match open parenthesis
>>
>> It seems to me like checkpatch.pl should have a special case for
>> networking code and that specific condition because fixing things to
>> make checkpatch.pl happy seems not to agree with the general coding
>> style recommended and enforced in the networking code.
>>
>> I just saw that new warning added popping up on a bunch of drivers
>> that were properly fixed to match the networking coding style before
>> submission.
>
>
> Sorry, I didn't get what you are saying...
>
> Is there any thing to be fixed in the patch ?

I think the "CHECK: Alignment should match open parenthesis" lines
reported by checkpatch.pl should not be fixed, the current code seems
fine according to the network subsystem coding standards.
-- 
Florian
