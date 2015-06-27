From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Issue with LACP mode in linux bonding driver
Date: Sat, 27 Jun 2015 07:57:06 +0530
Message-ID: <CADAe=++oN6FdmzqrzvXvT+83sS6mjSUDedmWMW6Vgh16M50ATA@mail.gmail.com>
References: <CADAe=+LvNgHV+crN_+E4xB+Pcz=KSvZpK5ADKzYFjHL2gGJq2Q@mail.gmail.com>
 <6462.1435284902@famine> <CADAe=+LmF_O5Tw_+kcg35urKBjJJOFZrYs3R2LNkdh-XW6r2ng@mail.gmail.com>
 <13466.1435353566@famine> <558DE6E2.5080207@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>, vfalico@gmail.com,
	gospo@cumulusnetworks.com, netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34973 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbbF0C1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 22:27:46 -0400
Received: by oiax193 with SMTP id x193so87162427oia.2
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 19:27:46 -0700 (PDT)
In-Reply-To: <558DE6E2.5080207@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks for the Update.

I agree with Jonathon and this change has to be picked by the stable
release. Configuration like this might end up creating huge
duplication of frames for end nodes.

Regards,
Ajith



On 27 June 2015 at 05:27, Jonathan Toppins <jtoppins@cumulusnetworks.com> wrote:
> On 6/26/15 5:19 PM, Jay Vosburgh wrote:
>>
>> Ajith Adapa <adapa.ajith@gmail.com> wrote:
>>
>>> On 26 June 2015 at 07:45, Jay Vosburgh <jay.vosburgh@canonical.com>
>>> wrote:
>>>>
>>>> echo 'module bonding =p' > /sys/kernel/debug/dynamic_debug/control
>>>
>>> Hi,
>>>
>>> thanks for the reply.
>>
>>
>>         I tried this out a bit here, and could reproduce the problem on
>> 3.13, but not on 4.0.0.  A bit of checking suggests that this problem is
>> fixed by the following commit:
>>
>> commit 63b46242f707849a1df10b70e026281bfa40e849
>> Author: Wilson Kok <wkok@cumulusnetworks.com>
>> Date:   Mon Jan 26 01:16:59 2015 -0500
>>
>>      bonding: fix incorrect lacp mux state when agg not active
>>
>
> Yes this should be picked up by the stable trees, apologies if I dropped the
> ball on cc'ing stable@. We (cumulus) are running a version of this patch in
> 3.2 code, so all stable trees should receive it.
>
> -Jon
