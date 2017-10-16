From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net/sched: cls_flower: Set egress_dev mark when
 calling into the HW driver
Date: Mon, 16 Oct 2017 14:41:50 +0200
Message-ID: <20171016124150.GA2112@nanopsycho>
References: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        mlxsw@mellanox.com, Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:47293 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751389AbdJPMlw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 08:41:52 -0400
Received: by mail-wm0-f68.google.com with SMTP id t69so2845547wmt.2
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 05:41:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 16, 2017 at 11:19:48AM CEST, ogerlitz@mellanox.com wrote:
>Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress
>Hardware device') made sure (when fl_hw_replace_filter is called) to put
>the egress_dev mark on persisent structure instance. Hence, following calls
>into the HW driver for stats and deletion will note it and act accordingly.
>
>With commit de4784ca030f this property is lost and hence when called,
>the HW driver failes to operate (stats, delete) on the offloaded flow.
>
>Fix it by setting the egress_dev flag whenever the ingress device is
>different from the hw device since this is exactly the condition under
>which we're calling into the HW driver through the egress port net-device.
>
>Fixes: de4784ca030f ('net: sched: get rid of struct tc_to_netdev')
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>Signed-off-by: Roi Dayan <roid@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
