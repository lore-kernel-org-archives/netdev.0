From: Andy Zhou <azhou@ovn.org>
Subject: Re: [userspace meter v3 0/5] Userspace meter
Date: Mon, 30 Jan 2017 23:05:01 -0800
Message-ID: <CABKoBm262Wy-NLHhSEkvSDrOQ4rymXo9aYUqWdUKGB5BPBKP9Q@mail.gmail.com>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andy Zhou <azhou@ovn.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:42050 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdAaHHK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:07:10 -0500
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 54E76C5A46
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:05:44 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id DLuRlynJmYKk for <netdev@vger.kernel.org>;
        Tue, 31 Jan 2017 08:05:43 +0100 (CET)
Received: from mail-ua0-f176.google.com (mail-ua0-f176.google.com [209.85.217.176])
        (Authenticated sender: azhou@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id CD6FCC5A55
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 08:05:42 +0100 (CET)
Received: by mail-ua0-f176.google.com with SMTP id 96so266731386uaq.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:05:42 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please discard this series. These are ovs user space changes, not
kernel changes. They are sent in error. Sorry.


On Mon, Jan 30, 2017 at 10:39 PM, Andy Zhou <azhou@ovn.org> wrote:
> Repost user space meter support. This is based Jarno's original work
> at: https://mail.openvswitch.org/pipermail/ovs-dev/2015-November/306304.html.
> With some enhancements, and rebased to current master.
>
> ---
> v1-v2: rebase and repost.
> v2-v3: simplify patch 2/5.
>
> Andy Zhou (2):
>   netdev-dummy: Add --len option for netdev-dummy/receive command
>   dp-packet: Enhance packet batch APIs.
>
> Jarno Rajahalme (3):
>   dpif: Meter framework.
>   ofproto: Meter translation.
>   dpif-netdev: Simple DROP meter implementation.
>
>  datapath/linux/compat/include/linux/openvswitch.h |   4 +-
>  include/openvswitch/ofp-actions.h                 |   1 +
>  lib/dp-packet.h                                   | 140 +++++--
>  lib/dpif-netdev.c                                 | 433 ++++++++++++++++++++--
>  lib/dpif-netlink.c                                |  46 ++-
>  lib/dpif-provider.h                               |  29 ++
>  lib/dpif.c                                        | 128 ++++++-
>  lib/dpif.h                                        |  13 +-
>  lib/netdev-dummy.c                                |  48 ++-
>  lib/netdev-linux.c                                |   3 +-
>  lib/netdev.c                                      |  24 +-
>  lib/odp-execute.c                                 |  58 +--
>  lib/odp-util.c                                    |  14 +
>  lib/ofp-actions.c                                 |   1 +
>  ofproto/ofproto-dpif-sflow.c                      |   1 +
>  ofproto/ofproto-dpif-xlate.c                      |  13 +-
>  ofproto/ofproto-dpif.c                            |  60 ++-
>  ofproto/ofproto-provider.h                        |  13 +-
>  ofproto/ofproto.c                                 |  51 +--
>  tests/dpif-netdev.at                              | 106 ++++++
>  tests/test-conntrack.c                            |  56 ++-
>  21 files changed, 1036 insertions(+), 206 deletions(-)
>
> --
> 1.9.1
>
