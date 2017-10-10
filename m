From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2] openvswitch: add ct_clear action
Date: Tue, 10 Oct 2017 16:34:29 -0700
Message-ID: <CAOrHB_AMzr-1uTRfE_xWLdTPwUPoz1Dwoobp3P1BkqQeL3qGzA@mail.gmail.com>
References: <20171010205444.20628-1-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>, Joe Stringer <joe@ovn.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:34320 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753369AbdJJXeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 19:34:31 -0400
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 4F4B2A80C4
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 01:34:30 +0200 (CEST)
Received: by mail-wm0-f43.google.com with SMTP id q132so1261554wmd.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 16:34:30 -0700 (PDT)
In-Reply-To: <20171010205444.20628-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 1:54 PM, Eric Garver <e@erig.me> wrote:
> This adds a ct_clear action for clearing conntrack state. ct_clear is
> currently implemented in OVS userspace, but is not backed by an action
> in the kernel datapath. This is useful for flows that may modify a
> packet tuple after a ct lookup has already occurred.
>
> Signed-off-by: Eric Garver <e@erig.me>
> ---
> v2:
>         - Use IP_CT_UNTRACKED for nf_ct_set()
>         - Only fill key if previously conntracked
>
Looks good.
Acked-by: Pravin B Shelar <pshelar@ovn.org>
