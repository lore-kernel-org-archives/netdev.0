From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: nft_reject_bridge: Fix powerpc
	build error
Date: Sun, 02 Nov 2014 23:17:30 -0500 (EST)
Message-ID: <20141102.231730.2267020727414912465.davem@davemloft.net>
References: <1414981155-27155-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, kaber@trash.net, pablo@netfilter.org
To: linux@roeck-us.net
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1414981155-27155-1-git-send-email-linux@roeck-us.net>
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

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun,  2 Nov 2014 18:19:15 -0800

> Fix:
> net/bridge/netfilter/nft_reject_bridge.c:
> In function 'nft_reject_br_send_v6_unreach':
> net/bridge/netfilter/nft_reject_bridge.c:240:3:
> 	error: implicit declaration of function 'csum_ipv6_magic'
>    csum_ipv6_magic(&nip6h->saddr, &nip6h->daddr,
>    ^
> make[3]: *** [net/bridge/netfilter/nft_reject_bridge.o] Error 1
> 
> Seen with powerpc:allmodconfig.
> 
> Fixes: 523b929d5446 ("netfilter: nft_reject_bridge: don't use IP stack to reject traffic")
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks.
