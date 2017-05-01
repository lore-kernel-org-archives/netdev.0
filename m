From: David Miller <davem@davemloft.net>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 01 May 2017 10:57:36 -0400 (EDT)
Message-ID: <20170501.105736.157375316602250235.davem@davemloft.net>
References: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
        <20170501143703.GA1285@lunn.ch>
        <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev@vger.kernel.org
To: heyen2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33296 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932951AbdEAO5q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:57:46 -0400
In-Reply-To: <CABM+yxmdJD2k1kA+fY9Yva24oB8BuDDhS-FQdY2EJM1ghf6xWw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: carl h <heyen2000@gmail.com>
Date: Mon, 1 May 2017 10:52:17 -0400

> But i can't see how the vlan info propagates down to the switch driver.

Which "VLAN info" are you talking about?

The VLANs configured onto the device itself or the per-packet VLAN
info.

Per-device VLAN configuration is communicated to the netdev driver
via netdev_ops->ndo_vlan_{add,kill}_vid().

Per-packet VLAN information is stored in skb->vlan_{proto,tci}.
