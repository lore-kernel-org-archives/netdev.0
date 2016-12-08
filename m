From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: 4.9.0-rc8: tg3 dead after resume
Date: Thu, 8 Dec 2016 14:33:49 +0530
Message-ID: <CAMet4B6t9neFPcGstZw6ebhFCBQzRsesStXZ8bjSaC5ggcuKxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <michael.chan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>
To: Billy Shuman <wshuman3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33504 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbcLHJEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 04:04:24 -0500
Received: by mail-qk0-f182.google.com with SMTP id x190so443807004qkb.0
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2016 01:03:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 8, 2016 at 12:14 AM, Billy Shuman <wshuman3@gmail.com> wrote:
> On Wed, Dec 7, 2016 at 12:37 PM, Michael Chan <michael.chan@broadcom.com> wrote:
>> On Wed, Dec 7, 2016 at 7:20 AM, Billy Shuman <wshuman3@gmail.com> wrote:
>>> After resume on 4.9.0-rc8 tg3 is dead.
>>>
>>> In logs I see:
>>> kernel: tg3 0000:44:00.0: phy probe failed, err -19
>>> kernel: tg3 0000:44:00.0: Problem fetching invariants of chip, aborting
>>
>> -19 is -ENODEV which means tg3 cannot read the PHY ID.
>>
>> If it's a true suspend/resume operation, the driver does not have to
>> go through probe during resume.  Please explain how you do
>> suspend/resume.
>>
>
> Sorry my previous message was accidentally sent to early.
>
> I used systemd (systemctl suspend) to suspend.
>
We need more information to proceed further.
Without suspend, Are you able to use the tg3 port?
Which Broadcom card are you having in laptop?
Please provide complete tg3 specific logs in dmesg.

>> Did this work before?  There has been very few changes to tg3 recently.
>>
>
> This is a new laptop for me, but the same behavior is seen on 4.4.36 and 4.8.12.
>
>>>
>>> rmmod and modprobe does not fix the problem only a reboot resolves the issue.
>>>
>>> Billy
