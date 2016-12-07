From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6 2/2] net/sched: cls_flower: Support matching
 on ICMP type and code
Date: Wed, 7 Dec 2016 14:06:30 +0100
Message-ID: <20161207130630.GG1987@nanopsycho>
References: <1481114908-24189-1-git-send-email-simon.horman@netronome.com>
 <1481114908-24189-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34267 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752532AbcLGNGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:06:33 -0500
Received: by mail-wm0-f67.google.com with SMTP id g23so27794123wme.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 05:06:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481114908-24189-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 07, 2016 at 01:48:28PM CET, simon.horman@netronome.com wrote:
>Support matching on ICMP type and code.
>
>Example usage:
>
>tc qdisc add dev eth0 ingress
>
>tc filter add dev eth0 protocol ip parent ffff: flower \
>	indev eth0 ip_proto icmp type 8 code 0 action drop
>
>tc filter add dev eth0 protocol ipv6 parent ffff: flower \
>	indev eth0 ip_proto icmpv6 type 128 code 0 action drop
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
