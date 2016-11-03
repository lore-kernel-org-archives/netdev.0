From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Support matching on SCTP
 ports
Date: Thu, 3 Nov 2016 13:31:04 +0100
Message-ID: <20161103123104.GA1757@nanopsycho.orion>
References: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36335 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754255AbcKCMbG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:31:06 -0400
Received: by mail-wm0-f54.google.com with SMTP id p190so330128109wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:31:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478175862-28642-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 03, 2016 at 01:24:21PM CET, simon.horman@netronome.com wrote:
>Support matching on SCTP ports in the same way that matching
>on TCP and UDP ports is already supported.
>
>Example usage:
>
>tc qdisc add dev eth0 ingress
>
>tc filter add dev eth0 protocol ip parent ffff: \
>        flower indev eth0 ip_proto sctp dst_port 80 \
>        action drop
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
