From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/3] mpls: move mpls_hdr to a common location
Date: Fri, 30 Sep 2016 11:20:33 -0700
Message-ID: <CAOrHB_B-Uqc9JBT9nLzUrdkKHGdEotSBBrzafBZfVbbvs7SoFg@mail.gmail.com>
References: <cover.1475255100.git.jbenc@redhat.com> <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
 <CAOrHB_BJqka5HGpeJ1GF42X2kQOmzrLY_LQt4Td6zrAX84Fjow@mail.gmail.com> <20160930195159.5b7eed00@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:54058 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932348AbcI3SUj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 14:20:39 -0400
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 7093341C08F
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 20:20:37 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id uX4EXUsP49oh for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 20:20:36 +0200 (CEST)
Received: from mail-it0-f43.google.com (mail-it0-f43.google.com [209.85.214.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 0967541C04C
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 20:20:35 +0200 (CEST)
Received: by mail-it0-f43.google.com with SMTP id u134so58697422itb.1
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 11:20:34 -0700 (PDT)
In-Reply-To: <20160930195159.5b7eed00@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 10:51 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Fri, 30 Sep 2016 10:43:42 -0700, pravin shelar wrote:
>> There is already struct mpls_label defined in uapi mpls header file.
>> Is there reason for not using it here?
>
> I think this should be unified as well. But it's for a different patch
> not related to this patchset. This patch just moves the existing
> mpls_hdr and mpls_shim_hdr definition to a new place.
>
> In general, I think the mpls code deserves a round of overall cleanups.
> It should not block this patchset, though. It can be considered as a
> step towards that goal.
>

Alright, I do not oppose this patch going in as it is.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
