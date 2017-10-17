From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net/sched: cls_flower: Set egress_dev mark when
 calling into the HW driver
Date: Tue, 17 Oct 2017 14:29:13 +0300
Message-ID: <1a523077-3c05-ba97-8a65-1967765b8d5a@cogentembedded.com>
References: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        mlxsw@mellanox.com, Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:56683 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932552AbdJQL3P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 07:29:15 -0400
Received: by mail-lf0-f46.google.com with SMTP id 90so1583088lfs.13
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 04:29:15 -0700 (PDT)
In-Reply-To: <1508145588-29959-1-git-send-email-ogerlitz@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/16/2017 12:19 PM, Or Gerlitz wrote:

> Commit 7091d8c '(net/sched: cls_flower: Add offload support using egress

    At least 12 digits are needed.

> Hardware device') made sure (when fl_hw_replace_filter is called) to put
> the egress_dev mark on persisent structure instance. Hence, following calls

    Persistent.

> into the HW driver for stats and deletion will note it and act accordingly.
> 
> With commit de4784ca030f this property is lost and hence when called,
> the HW driver failes to operate (stats, delete) on the offloaded flow.

    Fails.

> Fix it by setting the egress_dev flag whenever the ingress device is
> different from the hw device since this is exactly the condition under
> which we're calling into the HW driver through the egress port net-device.
> 
> Fixes: de4784ca030f ('net: sched: get rid of struct tc_to_netdev')
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Roi Dayan <roid@mellanox.com>
[...]

MBR, Sergei
