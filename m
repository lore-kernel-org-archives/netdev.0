From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next v2] openvswitch: Simplify do_execute_actions().
Date: Fri, 27 Jan 2017 21:35:39 -0800
Message-ID: <CAOrHB_DTpWirOLqE3NgkFXjzAytZwdpCwDwPbnaDF2ZmN_9mqg@mail.gmail.com>
References: <1485553528-16248-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:34954 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdA1FgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 00:36:22 -0500
Received: from mfilter18-d.gandi.net (mfilter18-d.gandi.net [217.70.178.146])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id 035D0C5A54
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 06:35:43 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter18-d.gandi.net (mfilter18-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id K92p6pKlscsq for <netdev@vger.kernel.org>;
        Sat, 28 Jan 2017 06:35:41 +0100 (CET)
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 9E671C5A50
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 06:35:41 +0100 (CET)
Received: by mail-io0-f170.google.com with SMTP id l66so75860821ioi.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 21:35:41 -0800 (PST)
In-Reply-To: <1485553528-16248-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 27, 2017 at 1:45 PM, Andy Zhou <azhou@ovn.org> wrote:
> do_execute_actions() implements a worthwhile optimization: in case
> an output action is the last action in an action list, skb_clone()
> can be avoided by outputing the current skb. However, the
> implementation is more complicated than necessary.  This patch
> simplify this logic.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
> v1->v2:  drop skb NULL check in do_output()
>

Acked-by: Pravin B Shelar <pshelar@ovn.org>

Thanks.
