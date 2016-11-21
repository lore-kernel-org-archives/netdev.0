From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v3 4/7] vxlan: improve vxlan route lookup checks.
Date: Mon, 21 Nov 2016 12:34:03 -0800
Message-ID: <CAOrHB_C3hvmZOL+P4kjw6i1+z09oRO8QQaZBjwxks2XqkgN2iw@mail.gmail.com>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
 <1479098638-4921-5-git-send-email-pshelar@ovn.org> <20161115153934.363e176d@griffin>
 <063D6719AE5E284EB5DD2968C1650D6DB0222355@AcuExch.aculab.com> <20161117165950.6a8ed0d0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:58731 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754480AbcKUUeI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 15:34:08 -0500
Received: from mfilter25-d.gandi.net (mfilter25-d.gandi.net [217.70.178.153])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 7B053A80CF
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:34:06 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter25-d.gandi.net (mfilter25-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id D5-sNQCuTaAo for <netdev@vger.kernel.org>;
        Mon, 21 Nov 2016 21:34:05 +0100 (CET)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id EC7ACA80CD
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 21:34:04 +0100 (CET)
Received: by mail-it0-f41.google.com with SMTP id j191so1457104ita.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 12:34:04 -0800 (PST)
In-Reply-To: <20161117165950.6a8ed0d0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 17, 2016 at 7:59 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Thu, 17 Nov 2016 10:17:01 +0000, David Laight wrote:
>> Worse than arbitrary, it adds 4 bytes of pad on 64bit systems.
>
> It does not, this is not a struct.
>
right.

After looking at the assembly code, it is clear that GCC and most of
modern compiler can reorder function variables for efficient storage.
