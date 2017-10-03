From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net] net: br: Fix igmp snooping offload with CONFIG_BRIDGE_VLAN_FILTERING
Date: Tue, 03 Oct 2017 10:57:36 -0400
Message-ID: <87d1649t3z.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506992111-25004-1-git-send-email-andrew@lunn.ch> <37af5488-a064-37dc-b1ce-373119ae7b05@lab.ntt.co.jp> <20171003121636.GB13548@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50564 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752077AbdJCO5l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 10:57:41 -0400
In-Reply-To: <20171003121636.GB13548@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> Now, i just noticed the switchdev call above. I don't think the DSA
> layer implements SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING. It probably
> should. So what is it supposed to do with this VLAN when filtering is
> disabled?

The DSA layer does implement SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING.
Its interpretation is to enable 802.1Q mode on targeted switch ports.
(hoping this is the correct thing to do.)
