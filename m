From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 0/7] nfp: flower vxlan tunnel offload
Date: Tue, 26 Sep 2017 16:31:35 +0200
Message-ID: <20170926163135.36d14a72@griffin>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
        <CAJ3xEMgfRuD2Y-P2eTKmXpciiopA8js4zbO_nNOA6J62sn--mw@mail.gmail.com>
        <20170925170451.GD18763@vergenet.net>
        <20170926121509.50a32571@griffin>
        <CAJ3xEMjEAhzC5=S7-dx8RiS=E7gYBBrtWY=9Cvqj-K3kyT9o3A@mail.gmail.com>
        <20170926145143.28bf52bd@griffin>
        <CAJ3xEMjOkF7vKHY=+q1dHXGdsyEXFPUa6dsGD_-M3+TX=DNouA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com, John Hurley <john.hurley@netronome.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Paul Blakey <paulb@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935644AbdIZObk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 10:31:40 -0400
In-Reply-To: <CAJ3xEMjOkF7vKHY=+q1dHXGdsyEXFPUa6dsGD_-M3+TX=DNouA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 17:17:02 +0300, Or Gerlitz wrote:
> maybe before/instead you call it a bug,

But it is a bug. When offloaded, the rules must not behave differently.
That's the fundamental thing about offloading. Here, the rules behave
differently when offloaded and when not. That's a bug.

> take a look on the design there and maybe
> tell us how to possibly do that otherwise?

I don't know the design. It's the responsibility of those who implement
the offloading to do it in the way that it's consistent with the
software path. That has always been the case.

This needs to be fixed. If it can't be fixed, the feature needs to be
reverted. It's not that Linux has to make use of every single offload
supported by hardware. If the offloading cannot be fit into how Linux
works, then the offload can't be supported. There are in fact many
precedents.

 Jiri
