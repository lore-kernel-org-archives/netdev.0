From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Apr 23 (netlink)
Date: Tue, 23 Apr 2013 11:04:18 -0700
Message-ID: <5176CD22.6070906@infradead.org>
References: <20130423180028.e08f92e6cc72105f67b77491@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130423180028.e08f92e6cc72105f67b77491@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/23/13 01:00, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20130422:
> 
> The net-next tree lost its build failure but gained another for which I
> applied a patch.
> 


when CONFIG_NETLINK_MMAP is not enabled:

net/netlink/diag.c: In function 'sk_diag_put_rings_cfg':
net/netlink/diag.c:28:17: error: 'struct netlink_sock' has no member named 'pg_vec_lock'
net/netlink/diag.c:29:29: error: 'struct netlink_sock' has no member named 'rx_ring'
net/netlink/diag.c:31:30: error: 'struct netlink_sock' has no member named 'tx_ring'
net/netlink/diag.c:33:19: error: 'struct netlink_sock' has no member named 'pg_vec_lock'


-- 
~Randy
