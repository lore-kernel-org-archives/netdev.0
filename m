From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] geneve: fix needed_headroom and max_mtu for collect_metadata
Date: Sat, 3 Jun 2017 22:34:43 -0700
Message-ID: <CAOrHB_CL75iYcRa=T3qDvaRrS__=7chdczGJierUw4BMv9aOEw@mail.gmail.com>
References: <20170602185410.10971-1-e@erig.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:34867 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750812AbdFDFnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 01:43:32 -0400
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 56DF4496C85
        for <netdev@vger.kernel.org>; Sun,  4 Jun 2017 07:34:47 +0200 (CEST)
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 1F2DD41C08A
        for <netdev@vger.kernel.org>; Sun,  4 Jun 2017 07:34:46 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 6IAyav5tbI0T for <netdev@vger.kernel.org>;
        Sun,  4 Jun 2017 07:34:44 +0200 (CEST)
Received: from mail-wr0-f177.google.com (mail-wr0-f177.google.com [209.85.128.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id CA65E41C089
        for <netdev@vger.kernel.org>; Sun,  4 Jun 2017 07:34:44 +0200 (CEST)
Received: by mail-wr0-f177.google.com with SMTP id v111so17009333wrc.3
        for <netdev@vger.kernel.org>; Sat, 03 Jun 2017 22:34:44 -0700 (PDT)
In-Reply-To: <20170602185410.10971-1-e@erig.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 2, 2017 at 11:54 AM, Eric Garver <e@erig.me> wrote:
> Since commit 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> when using COLLECT_METADATA geneve devices are created with too small of
> a needed_headroom and too large of a max_mtu. This is because
> ip_tunnel_info_af() is not valid with the device level info when using
> COLLECT_METADATA and we mistakenly fall into the IPv4 case.
>
> For COLLECT_METADATA, always use the worst case of ipv6 since both
> sockets are created.
>
> Fixes: 9b4437a5b870 ("geneve: Unify LWT and netdev handling.")
> Signed-off-by: Eric Garver <e@erig.me>

Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
