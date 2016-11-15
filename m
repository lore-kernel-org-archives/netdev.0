From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 3/7] vxlan: simplify exception handling
Date: Tue, 15 Nov 2016 09:15:56 -0800
Message-ID: <CAOrHB_AKP+4rg90YJ4puSziLnmX+3tu4uuGe-_=OJSoXVk-E5w@mail.gmail.com>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
 <1479098638-4921-4-git-send-email-pshelar@ovn.org> <20161115153014.38fa2480@griffin>
 <CAOrHB_CQEeknxznNu5u=PhD8pGdPxg+HBinTu7+rz77tj2+wNg@mail.gmail.com> <20161115180453.26105ba8@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:58970 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932956AbcKORQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 12:16:17 -0500
Received: from mfilter36-d.gandi.net (mfilter36-d.gandi.net [217.70.178.167])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 0B539FB8A1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 18:16:15 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter36-d.gandi.net (mfilter36-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id G5LVuLHTEzYD for <netdev@vger.kernel.org>;
        Tue, 15 Nov 2016 18:16:13 +0100 (CET)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 1FC92FB8DA
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 18:16:12 +0100 (CET)
Received: by mail-it0-f46.google.com with SMTP id o1so10689316ito.1
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 09:16:12 -0800 (PST)
In-Reply-To: <20161115180453.26105ba8@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 9:04 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Tue, 15 Nov 2016 08:40:58 -0800, Pravin Shelar wrote:
>> On Tue, Nov 15, 2016 at 6:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
>> > It would be a bit cleaner to do this assignment just after rt is
>> > assigned (but after the IS_ERR(rt) condition), get rid of the added
>> > ip_rt_put call above and move the existing ip_rt_put call in the bypass
>> > case just before the vxlan_encap_bypass call...
>> >
>> Does it really matters given that next patches in this series moves
>> this duplicate code and does pretty much what you are describing?
>
> Okay, right. I tried to look also at patches further in the series but
> it seemed to me this will leave an instance of ip_rt_put that could be
> avoided. But it will not.
>
> Acked-by: Jiri Benc <jbenc@redhat.com>
>
> (It would make the reviewers' life easier if the individual patches
> were more self contained. Ideally, each patch should be able to stand
> on its own. This unrelated code shuffling makes it too easy to miss
> things...)
>
I tried to keep one patch targeting single cleanup. But all patches
targeted same code, that makes it dependent on each other.

> Anyway, thanks for the cleanup!
>

Thanks for all reviews.
