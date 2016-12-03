From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Possible regression due to "net/sched: cls_flower: Add offload
 support using egress Hardware device"
Date: Sat, 3 Dec 2016 18:06:08 +0200
Message-ID: <CAJ3xEMiTgDq-qE_HEdGc-F7U24Be+XS6RtsG-22zUzrV1Z_neA@mail.gmail.com>
References: <20161203131758.GA4695@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Roi Dayan <roid@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36386 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbcLCQGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 11:06:09 -0500
Received: by mail-oi0-f65.google.com with SMTP id u15so31299377oie.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 08:06:08 -0800 (PST)
In-Reply-To: <20161203131758.GA4695@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 3, 2016 at 3:17 PM, Simon Horman <horms@verge.net.au> wrote:

> in net-next I am observing what appears to be an regression in net-next due to:
> 7091d8c7055d ("net/sched: cls_flower: Add offload support using egress Hardware device")
>
> The problem occurs when adding a flower filter (without offload to a virtio device).

> # ethtool -d eth0
> ethtool -i eth0
> driver: virtio_net

> # tc qdisc add dev eth0 ingress
> # tc filter add dev eth0 protocol ip parent ffff: flower indev eth0
> [  104.302779] BUG: unable to handle kernel NULL pointer dereference at 00000000000000d5

Simon, I don't see an action here, is that missing in purpose? wasn't
sure what such filter does, but ofcourse
if it was supported by the patches it has to be so after changing
things as well, we will check and fix.

Or.
