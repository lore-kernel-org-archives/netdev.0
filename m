From: Billy Shuman <wshuman3@gmail.com>
Subject: Re: 4.9.0-rc8: tg3 dead after resume
Date: Wed, 7 Dec 2016 13:44:51 -0500
Message-ID: <CAHQNsocKsMrfuiiknYve5UViBwm-i29J0274CTMSsWJOunWSxA@mail.gmail.com>
References: <CAHQNsodiku6Ln3y-=GzmmNLM0Emc2rEheFmc80OCuN91roojqA@mail.gmail.com>
 <CACKFLinTBokAXnOri9_sxuFby0y4VxxrhEOh1aayPsyPWwDahw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35158 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752435AbcLGSvj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 13:51:39 -0500
Received: by mail-io0-f170.google.com with SMTP id a124so727611254ioe.2
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 10:51:38 -0800 (PST)
In-Reply-To: <CACKFLinTBokAXnOri9_sxuFby0y4VxxrhEOh1aayPsyPWwDahw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 12:37 PM, Michael Chan <michael.chan@broadcom.com> wrote:
> On Wed, Dec 7, 2016 at 7:20 AM, Billy Shuman <wshuman3@gmail.com> wrote:
>> After resume on 4.9.0-rc8 tg3 is dead.
>>
>> In logs I see:
>> kernel: tg3 0000:44:00.0: phy probe failed, err -19
>> kernel: tg3 0000:44:00.0: Problem fetching invariants of chip, aborting
>
> -19 is -ENODEV which means tg3 cannot read the PHY ID.
>
> If it's a true suspend/resume operation, the driver does not have to
> go through probe during resume.  Please explain how you do
> suspend/resume.
>

Sorry my previous message was accidentally sent to early.

I used systemd (systemctl suspend) to suspend.

> Did this work before?  There has been very few changes to tg3 recently.
>

This is a new laptop for me, but the same behavior is seen on 4.4.36 and 4.8.12.

>>
>> rmmod and modprobe does not fix the problem only a reboot resolves the issue.
>>
>> Billy
