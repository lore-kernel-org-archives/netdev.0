From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 v3 4/4] ifstat: Add "sw only" extended statistics
 to ifstat
Date: Thu, 22 Dec 2016 13:10:19 -0800
Message-ID: <585C413B.9050905@cumulusnetworks.com>
References: <1482423795-6531-1-git-send-email-nogahf@mellanox.com> <1482423795-6531-5-git-send-email-nogahf@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
        roszenrami@gmail.com, ogerlitz@mellanox.com, jiri@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, idosch@mellanox.com
To: Nogah Frankel <nogahf@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34721 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756545AbcLVVKW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 16:10:22 -0500
Received: by mail-pg0-f45.google.com with SMTP id y62so49436423pgy.1
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2016 13:10:22 -0800 (PST)
In-Reply-To: <1482423795-6531-5-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/16, 8:23 AM, Nogah Frankel wrote:
> Add support for extended statistics of SW only type, for counting only the
> packets that went via the cpu. (useful for systems with forward
> offloading). It reads it from filter type IFLA_STATS_LINK_OFFLOAD_XSTATS
> and sub type IFLA_OFFLOAD_XSTATS_CPU_HIT.
>
> It is under the name 'software'
> (or any shorten of it as 'soft' or simply 's')
>
> For example:
> ifstat -x s
>
>
Nogah, can we keep the option names closer to the attribute names ?
That would avoid some confusion and help with the follow-up stats.

ifstat -x offload cpu
or
ifstat -x cpu

for others it would be:

ifstat -x link [vlan|igmp]
ifstat -x vlan
ifstat -x igmp
ifstat -x lacp

and so on...

thanks!
