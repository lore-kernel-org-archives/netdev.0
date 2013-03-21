From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netlink: Diag core and basic socket info dumping
 (v2)
Date: Thu, 21 Mar 2013 12:38:35 -0400 (EDT)
Message-ID: <20130321.123835.105179567859494344.davem@davemloft.net>
References: <1363883628-7249-1-git-send-email-avagin@openvz.org>
	<1363883628-7249-4-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xemul@parallels.com, edumazet@google.com, pablo@netfilter.org,
	ebiederm@xmission.com, gaofeng@cn.fujitsu.com, tgraf@suug.ch
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363883628-7249-4-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Thu, 21 Mar 2013 20:33:48 +0400

> The netlink_diag can be built as a module, just like it's done in
> unix sockets.
> 
> The core dumping message carries the basic info about netlink sockets:
> family, type and protocol, portis, dst_group, dst_portid, state.
> 
> Groups can be received as an optional parameter NETLINK_DIAG_GROUPS.
> 
> Netlink sockets cab be filtered by protocols.
> 
> The socket inode number and cookie is reserved for future per-socket info
> retrieving. The per-protocol filtering is also reserved for future by
> requiring the sdiag_protocol to be zero.
> 
> The file /proc/net/netlink doesn't provide enough information for
> dumping netlink sockets. It doesn't provide dst_group, dst_portid,
> groups above 32.
> 
> v2: fix NETLINK_DIAG_MAX. Now it's equal to the last constant.
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied to net-next
