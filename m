From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v2 1/4] openvswitch:
 Deferred fifo API change.
Date: Thu, 16 Mar 2017 10:28:18 -0700
Message-ID: <CAOrHB_B9_HpA38SL8V66=wOi9enTpgQ_Di-Kf5CUJ0oLPS97xA@mail.gmail.com>
References: <1489532891-33497-1-git-send-email-azhou@ovn.org> <1489532891-33497-2-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:50447 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751478AbdCPR30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:29:26 -0400
Received: from mfilter11-d.gandi.net (mfilter11-d.gandi.net [217.70.178.131])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id E27E6C5A9A
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:28:20 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter11-d.gandi.net (mfilter11-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id VDzQPBLsu0tu for <netdev@vger.kernel.org>;
        Thu, 16 Mar 2017 18:28:19 +0100 (CET)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 98858C5A78
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 18:28:19 +0100 (CET)
Received: by mail-wm0-f43.google.com with SMTP id n11so53853484wma.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:28:19 -0700 (PDT)
In-Reply-To: <1489532891-33497-2-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 4:08 PM, Andy Zhou <azhou@ovn.org> wrote:
> add_deferred_actions() API currently requires actions to be passed in
> as a fully encoded netlink message. So far both 'sample' and 'recirc'
> actions happens to carry actions as fully encoded netlink messages.
> However, this requirement is more restrictive than necessary, future
> patch will need to pass in action lists that are not fully encoded
> by themselves.

It is not obvious why this change is required?
can you explain it.
