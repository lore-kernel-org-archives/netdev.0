From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v13 5/8] openvswitch: add processing of L3 packets
Date: Sat, 12 Nov 2016 15:58:29 -0800
Message-ID: <CAOrHB_DMQf7zQ+q-REmNeTY7CN6uG9kUaYbtSkB=AiNcoL=u2A@mail.gmail.com>
References: <cover.1478791347.git.jbenc@redhat.com> <05254a13fdb29c1c3eaa1840ba2d127d98f8c418.1478791347.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:56407 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbcKLX6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2016 18:58:34 -0500
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id D9591A80C1
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 00:58:32 +0100 (CET)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3AI4AeGOgXkZ for <netdev@vger.kernel.org>;
        Sun, 13 Nov 2016 00:58:31 +0100 (CET)
Received: from mail-it0-f50.google.com (mail-it0-f50.google.com [209.85.214.50])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 4EA9EA80C6
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 00:58:31 +0100 (CET)
Received: by mail-it0-f50.google.com with SMTP id q124so38673759itd.1
        for <netdev@vger.kernel.org>; Sat, 12 Nov 2016 15:58:31 -0800 (PST)
In-Reply-To: <05254a13fdb29c1c3eaa1840ba2d127d98f8c418.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 7:28 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Support receiving, extracting flow key and sending of L3 packets (packets
> without an Ethernet header).
>
> Note that even after this patch, non-Ethernet interfaces are still not
> allowed to be added to bridges. Similarly, netlink interface for sending and
> receiving L3 packets to/from user space is not in place yet.
>
> Based on previous versions by Lorand Jakab and Simon Horman.
>
> Signed-off-by: Lorand Jakab <lojakab@cisco.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v13:
> - fix incorrect setting of packet to NULL in ovs_packet_cmd_execute
> - dropping packet for interfaces with wrong type
> ---

Thanks for working on this.

Acked-by: Pravin B Shelar <pshelar@ovn.org>
