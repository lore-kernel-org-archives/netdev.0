From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net] openvswitch: fix potential out of bound access in parse_ct
Date: Sun, 23 Jul 2017 09:58:00 -0700
Message-ID: <CAOrHB_AcMimVYEEwKdn_3w-R72SUg1fQFk9r18KkDagMKG6w-A@mail.gmail.com>
References: <1500803543-7297-1-git-send-email-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@nicira.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Liping Zhang <zlpnobody@gmail.com>
To: Liping Zhang <zlpnobody@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:34130 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdGWQ6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Jul 2017 12:58:04 -0400
Received: from mfilter10-d.gandi.net (mfilter10-d.gandi.net [217.70.178.139])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 5946AA80C2
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 18:58:03 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter10-d.gandi.net (mfilter10-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id dyAfkHh5ESJv for <netdev@vger.kernel.org>;
        Sun, 23 Jul 2017 18:58:02 +0200 (CEST)
Received: from mail-wr0-f174.google.com (mail-wr0-f174.google.com [209.85.128.174])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 0A162A80CF
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 18:58:01 +0200 (CEST)
Received: by mail-wr0-f174.google.com with SMTP id k71so44428587wrc.2
        for <netdev@vger.kernel.org>; Sun, 23 Jul 2017 09:58:01 -0700 (PDT)
In-Reply-To: <1500803543-7297-1-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 23, 2017 at 2:52 AM, Liping Zhang <zlpnobody@163.com> wrote:
> From: Liping Zhang <zlpnobody@gmail.com>
>
> Before the 'type' is validated, we shouldn't use it to fetch the
> ovs_ct_attr_lens's minlen and maxlen, else, out of bound access
> may happen.
>
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Liping Zhang <zlpnobody@gmail.com>

Good catch!
Acked-by: Pravin B Shelar <pshelar@ovn.org>
