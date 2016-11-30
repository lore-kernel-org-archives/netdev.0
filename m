From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: Support adding ingress tc rule
 when egress device flag is set
Date: Wed, 30 Nov 2016 19:10:56 +0200
Message-ID: <CAJ3xEMjbKQSiC0Uqw2vQoaK2VfNkvKgYOo=-aACyq9a8gghm5g@mail.gmail.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
 <1480516895-29545-9-git-send-email-hadarh@mellanox.com> <583F0007.3090507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35835 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753679AbcK3RK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:10:57 -0500
Received: by mail-oi0-f65.google.com with SMTP id v84so23801224oie.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 09:10:57 -0800 (PST)
In-Reply-To: <583F0007.3090507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 6:36 PM, John Fastabend
<john.fastabend@gmail.com> wrote:

> I started to dig through these patches and the last series here,
>
>    Re: [PATCH net-next 00/13] Mellanox 100G SRIOV offloads tunnel_key
> set/release

> Can you explain how these two are related? I'm guessing in that first
> series the actual redirect action to a tunnel device was being ignore?

> Does this series clean up that bit of software/hardware alignment.

If only the 1st series is applied, the kernel pieces are functional
but with user-space
manually putting the decap (tunnel key release) TC rule on the uplink device
(tc tool -> UAPI --> tc core --> flower --> mlx5), but under real life
use-case, the rule
is put on shared-tunnel device, so this series adds on the prev one.

Or.
