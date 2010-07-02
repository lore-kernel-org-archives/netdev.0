From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 1/9] netfilter: nf_nat: support user-specified SNAT rules
 in LOCAL_IN
Date: Fri, 2 Jul 2010 12:14:06 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007021212490.16691@obet.zrqbmnf.qr>
References: <1278064342-19059-1-git-send-email-kaber@trash.net> <1278064342-19059-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-07-02 11:52, kaber@trash.net wrote:
>
>2.6.34 introduced 'conntrack zones' to deal with cases where packets
>from multiple identical networks are handled by conntrack/NAT. Packets
>are looped through veth devices, during which they are NATed to private
>addresses, after which they can continue normally through the stack
>and possibly have NAT rules applied a second time.
>
>This works well, but is needlessly complicated for cases where only
>a single SNAT/DNAT mapping needs to be applied to these packets.

I still have not grasped why SNAT is needed in the INPUT path. For the
tunnel scenario that you wanted to build I could not find a reason to
do SNAT in that place - since the non-encapsulated packets don't go
through INPUT anyway.
