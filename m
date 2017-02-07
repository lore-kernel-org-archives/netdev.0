From: Joe Stringer <joe@ovn.org>
Subject: Re: kernel data plane
Date: Tue, 7 Feb 2017 10:03:10 -0800
Message-ID: <CAPWQB7ELZLECr7AABOx-2K-yTPGiO1qz6ErFg69eUJt9hxrr5g@mail.gmail.com>
References: <20170207.124528.1236430562373810535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin B Shelar <pshelar@nicira.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:46698 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754538AbdBGSDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 13:03:54 -0500
Received: from mfilter47-d.gandi.net (mfilter47-d.gandi.net [217.70.178.178])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 42E7341C08D
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 19:03:33 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter47-d.gandi.net (mfilter47-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id XxFfWX3o5GY9 for <netdev@vger.kernel.org>;
        Tue,  7 Feb 2017 19:03:31 +0100 (CET)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id B960141C08F
        for <netdev@vger.kernel.org>; Tue,  7 Feb 2017 19:03:31 +0100 (CET)
Received: by mail-qk0-f178.google.com with SMTP id u25so96175879qki.2
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 10:03:31 -0800 (PST)
In-Reply-To: <20170207.124528.1236430562373810535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 February 2017 at 09:45, David Miller <davem@davemloft.net> wrote:
>
> Since I see that you guys have marked the kernel data plane of
> openvswitch as experimental and that it "has not been thoroughly
> tested" what is your long term plan for deprecation and eventual
> removal of it from the tree?
>
>         https://github.com/openvswitch/ovs/commit/602e24ee189b76a72fdd26c9ed70c5f6b919a2f3

That's not the kernel dataplane being marked as experimental.
Specifically, the entire sentence states:

"The *userspace-only* mode of Open vSwitch without DPDK is considered
experimental. It has not been thoroughly tested." (my emphasis)

OVS provides a userspace datapath, which is shared between a version
that uses DPDK devices and a version that uses tap devices. Previously
both of these were marked as experimental. Over the past year the
OVS-DPDK developers have been pushing to relax/remove this tag from
the DPDK portion; this patch leaves the experimental tag in place for
the version that does not use DPDK.

>
> If it's experimental and not being tested, I'm not too thrilled about
> new feature patches and whatnot being posted which require developer
> resources to audit and review if the official message is "don't use
> this."

The kernel openvswitch is very much still maintained, tested, and will
continue to be used.
