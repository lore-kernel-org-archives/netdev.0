From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v12 1/9] openvswitch: use hard_header_len instead
 of hardcoded ETH_HLEN
Date: Tue, 18 Oct 2016 22:13:53 -0700
Message-ID: <CAOrHB_C1LuA=pPm7CoVk6Hrkvi-0V54DP2vx9ADV6gx9qUWntg@mail.gmail.com>
References: <cover.1476708212.git.jbenc@redhat.com> <eef37b3c7e1c1deffd6a5a8cfff83cd2c82cb76b.1476708212.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        ovs dev <dev@openvswitch.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:55488 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755278AbcJSFN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 01:13:58 -0400
Received: from mfilter34-d.gandi.net (mfilter34-d.gandi.net [217.70.178.165])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 604E5C5A50
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:13:57 +0200 (CEST)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter34-d.gandi.net (mfilter34-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id CbSVG3IamRFy for <netdev@vger.kernel.org>;
        Wed, 19 Oct 2016 07:13:55 +0200 (CEST)
Received: from mail-it0-f47.google.com (mail-it0-f47.google.com [209.85.214.47])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 351C1C5A44
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:13:55 +0200 (CEST)
Received: by mail-it0-f47.google.com with SMTP id m138so18432743itm.0
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 22:13:55 -0700 (PDT)
In-Reply-To: <eef37b3c7e1c1deffd6a5a8cfff83cd2c82cb76b.1476708212.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 6:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On tx, use hard_header_len while deciding whether to refragment or drop the
> packet. That way, all combinations are calculated correctly:
>
> * L2 packet going to L2 interface (the L2 header len is subtracted),
> * L2 packet going to L3 interface (the L2 header is included in the packet
>   lenght),
> * L3 packet going to L3 interface.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
