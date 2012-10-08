From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vlan: don't deliver frames for unknown vlans to
 protocols
Date: Mon, 08 Oct 2012 15:22:21 -0400 (EDT)
Message-ID: <20121008.152221.1598558544115876006.davem@davemloft.net>
References: <20121008015158.GE25895@florz.florz.dyndns.org>
	<20121008.144230.1404596032615788891.davem@davemloft.net>
	<20121008191944.GD25288@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jpirko@redhat.com
To: florz@florz.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121008191944.GD25288@florz.florz.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Zumbiehl <florz@florz.de>
Date: Mon, 8 Oct 2012 21:19:44 +0200

> The only way to reach the new check without another_round and with a
> non-zero tag is the first return false, which happens if there is no device
> for the tag, in which case setting PACKET_OTHERHOST should be the right
> thing to do (in particular, a non-existent vlan device won't have the
> frame's MAC address). I am assuming that rx_handlers don't modify the
> frame unless they return RX_HANDLER_ANOTHER.

Indeed, you're right.

Patch applied and queued up for -stable, thanks.
