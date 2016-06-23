From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] bridge: netfilter: spanning tree: Add
 masked_ether_addr_equal and neatening
Date: Thu, 23 Jun 2016 19:36:59 +0200
Message-ID: <20160623173659.GA3474@salvia>
References: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <f39576f17e9f5dee35258917917f2d740e820a77.1466024030.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 15, 2016 at 01:58:45PM -0700, Joe Perches wrote:
> There is code duplication of a masked ethernet address comparison here
> so make it a separate function instead.
> 
> Miscellanea:
> 
> o Neaten alignment of FWINV macro uses to make it clearer for the reader

Applied, thanks.

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
> 
> This masked_ether_addr_equal function could go into etherdevice.h,
> but I don't see another use like it in kernel code.  Is there one?

This is specific of iptables, not even nftables would use this. So I
would keep this in the iptables tree.
