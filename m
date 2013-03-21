From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 2/2] netlink: Diag core and basic socket info dumping
Date: Thu, 21 Mar 2013 15:46:26 +0400
Message-ID: <514AF312.9010309@parallels.com>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org> <1363857669-19990-3-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36041 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757506Ab3CULrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 07:47:16 -0400
In-Reply-To: <1363857669-19990-3-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2013 01:21 PM, Andrey Vagin wrote:
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
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
