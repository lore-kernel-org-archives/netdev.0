From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] openvswitch: Add erspan tunnel support.
Date: Wed, 4 Oct 2017 14:31:00 -0700
Message-ID: <CAOrHB_DNkfnUty=QzO5d6SAyscLXBP-teE_j0RvDaJiMHqRaaw@mail.gmail.com>
References: <1507118559-13774-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Tu <u9012063@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:59491 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdJDVbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 17:31:02 -0400
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 3F5F4A80CB
        for <netdev@vger.kernel.org>; Wed,  4 Oct 2017 23:31:01 +0200 (CEST)
Received: by mail-wm0-f53.google.com with SMTP id k4so23575805wmc.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 14:31:01 -0700 (PDT)
In-Reply-To: <1507118559-13774-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 4, 2017 at 5:02 AM, William Tu <u9012063@gmail.com> wrote:
> Add type II erspan vport implementation.  Since erspan protocol is
> on top of the GRE header, the implementation is extended from the
> existing gre implementation.
>
> Signed-off-by: William Tu <u9012063@gmail.com>
> Cc: Pravin B Shelar <pshelar@ovn.org>

Why are you adding ERSPAN support to compat code. Isn't this supported
over OVS netlink-rtnl (dpif-netlink-rtnl)?
