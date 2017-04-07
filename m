From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/3] net: dsa: Move skb_unshare() to dsa_switch_rcv()
Date: Fri, 07 Apr 2017 16:53:49 -0400
Message-ID: <8760igvt0i.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170407204154.9651-1-f.fainelli@gmail.com> <20170407204154.9651-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42610 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754895AbdDGUz2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 16:55:28 -0400
In-Reply-To: <20170407204154.9651-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <f.fainelli@gmail.com> writes:

> All DSA tag receive functions need to unshare the skb before mangling it, move
> this to the generic dsa_switch_rcv() function which will allow us to make the
> tag receive function return their mangled skb without caring about freeing a
> NULL skb.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
