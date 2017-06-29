From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v3] datapath: Avoid using stack larger than 1024.
Date: Thu, 29 Jun 2017 10:45:42 -0700
Message-ID: <CAOrHB_B7PpKMdVn8JNG9B-R6i80Zxn8rEBBptCSKCTz6TdsU6g@mail.gmail.com>
References: <1498700323-98406-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Greg Rose <gvrose8192@gmail.com>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:43440 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752609AbdF2Rpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 13:45:46 -0400
Received: from mfilter10-d.gandi.net (mfilter10-d.gandi.net [217.70.178.139])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id 1A6C3A80CE
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 19:45:45 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter10-d.gandi.net (mfilter10-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id XUvnQH2kIn71 for <netdev@vger.kernel.org>;
        Thu, 29 Jun 2017 19:45:43 +0200 (CEST)
Received: from mail-wr0-f179.google.com (mail-wr0-f179.google.com [209.85.128.179])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 89282A80C1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 19:45:43 +0200 (CEST)
Received: by mail-wr0-f179.google.com with SMTP id 77so193241035wrb.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 10:45:43 -0700 (PDT)
In-Reply-To: <1498700323-98406-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 6:38 PM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
> When compiling OvS-master on 4.4.0-81 kernel,
> there is a warning:
>
>     CC [M]  /root/ovs/datapath/linux/datapath.o
>     /root/ovs/datapath/linux/datapath.c: In function
>     'ovs_flow_cmd_set':
>     /root/ovs/datapath/linux/datapath.c:1221:1: warning:
>     the frame size of 1040 bytes is larger than 1024 bytes
>     [-Wframe-larger-than=]
>
> This patch factors out match-init and action-copy to avoid
> "Wframe-larger-than=1024" warning. Because mask is only
> used to get actions, we new a function to save some
> stack space.
>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
Looks good, you have to submit patch against net-next for upstream OVS
module first.
