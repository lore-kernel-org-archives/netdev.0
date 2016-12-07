From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: 4.9.0-rc8: tg3 dead after resume
Date: Wed, 7 Dec 2016 09:37:17 -0800
Message-ID: <CACKFLinTBokAXnOri9_sxuFby0y4VxxrhEOh1aayPsyPWwDahw@mail.gmail.com>
References: <CAHQNsodiku6Ln3y-=GzmmNLM0Emc2rEheFmc80OCuN91roojqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>
To: Billy Shuman <wshuman3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36245 "EHLO
        mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932366AbcLGRhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:37:18 -0500
Received: by mail-oi0-f41.google.com with SMTP id v84so423962231oie.3
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 09:37:18 -0800 (PST)
In-Reply-To: <CAHQNsodiku6Ln3y-=GzmmNLM0Emc2rEheFmc80OCuN91roojqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016 at 7:20 AM, Billy Shuman <wshuman3@gmail.com> wrote:
> After resume on 4.9.0-rc8 tg3 is dead.
>
> In logs I see:
> kernel: tg3 0000:44:00.0: phy probe failed, err -19
> kernel: tg3 0000:44:00.0: Problem fetching invariants of chip, aborting

-19 is -ENODEV which means tg3 cannot read the PHY ID.

If it's a true suspend/resume operation, the driver does not have to
go through probe during resume.  Please explain how you do
suspend/resume.

Did this work before?  There has been very few changes to tg3 recently.

>
> rmmod and modprobe does not fix the problem only a reboot resolves the issue.
>
> Billy
