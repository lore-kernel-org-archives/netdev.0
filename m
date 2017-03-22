From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v4 1/4] openvswitch:
 Deferred fifo API change.
Date: Tue, 21 Mar 2017 22:59:36 -0700
Message-ID: <CAOrHB_BQfUwVQ8T-V72wbU-SzRso8xavsurMvyaKbop9fm3Qrg@mail.gmail.com>
References: <1490052750-60187-1-git-send-email-azhou@ovn.org> <1490052750-60187-2-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:36370 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758022AbdCVGAs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 02:00:48 -0400
Received: from mfilter16-d.gandi.net (mfilter16-d.gandi.net [217.70.178.144])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 6267041C084
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:39 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter16-d.gandi.net (mfilter16-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id aNSUED32eD_E for <netdev@vger.kernel.org>;
        Wed, 22 Mar 2017 06:59:37 +0100 (CET)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 2DC4741C087
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 06:59:37 +0100 (CET)
Received: by mail-wm0-f49.google.com with SMTP id t189so27423968wmt.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 22:59:37 -0700 (PDT)
In-Reply-To: <1490052750-60187-2-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 4:32 PM, Andy Zhou <azhou@ovn.org> wrote:
> add_deferred_actions() API currently requires actions to be passed in
> as a fully encoded netlink message. So far both 'sample' and 'recirc'
> actions happens to carry actions as fully encoded netlink messages.
> However, this requirement is more restrictive than necessary, future
> patch will need to pass in action lists that are not fully encoded
> by themselves.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
