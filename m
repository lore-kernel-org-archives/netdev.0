From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 2/3] openvswitch: fix vlan subtraction from packet length
Date: Mon, 10 Oct 2016 13:05:41 -0700
Message-ID: <CAOrHB_CBmUSSgZGSQXY1=vJGzUrOEmas5nWcULkQ_c=1Ju2mdw@mail.gmail.com>
References: <cover.1476111550.git.jbenc@redhat.com> <310ec523056b4f4747e800333498ef27ad1248aa.1476111550.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:53968 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbcJJUFw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 16:05:52 -0400
Received: from mfilter42-d.gandi.net (mfilter42-d.gandi.net [217.70.178.172])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id B08211720A9
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:44 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter42-d.gandi.net (mfilter42-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id IqOekegTlw3X for <netdev@vger.kernel.org>;
        Mon, 10 Oct 2016 22:05:43 +0200 (CEST)
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 1410717209B
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 22:05:42 +0200 (CEST)
Received: by mail-io0-f176.google.com with SMTP id i202so4089762ioi.2
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2016 13:05:42 -0700 (PDT)
In-Reply-To: <310ec523056b4f4747e800333498ef27ad1248aa.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 10, 2016 at 8:02 AM, Jiri Benc <jbenc@redhat.com> wrote:
> When the packet has its vlan tag in skb->vlan_tci, the length of the VLAN
> header is not counted in skb->len. It doesn't make sense to subtract it.
>
> Fixes: 018c1dda5ff1 ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
