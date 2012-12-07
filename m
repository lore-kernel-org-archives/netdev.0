From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v5] bridge: export multicast database via netlink
Date: Fri, 7 Dec 2012 10:36:29 +0000
Message-ID: <20121207103629.GB2996@casper.infradead.org>
References: <1354874688-24564-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46710 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932509Ab2LGKga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 05:36:30 -0500
Content-Disposition: inline
In-Reply-To: <1354874688-24564-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/12 at 06:04pm, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> V5: fix two bugs pointed out by Thomas
>     remove seq check for now, mark it as TODO
> 
> V4: remove some useless #include
>     some coding style fix
> 
> V3: drop debugging printk's
>     update selinux perm table as well
> 
> V2: drop patch 1/2, export ifindex directly
>     Redesign netlink attributes
>     Improve netlink seq check
>     Handle IPv6 addr as well
> 
> This patch exports bridge multicast database via netlink
> message type RTM_GETMDB. Similar to fdb, but currently bridge-specific.
> We may need to support modify multicast database too (RTM_{ADD,DEL}MDB).
> 
> (Thanks to Thomas for patient reviews)
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
