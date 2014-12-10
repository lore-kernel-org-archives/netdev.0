From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: Add ability to always enable
	TSO/UFO
Date: Wed, 10 Dec 2014 14:50:47 -0500 (EST)
Message-ID: <20141210.145047.1148744559031706340.davem@davemloft.net>
References: <1418179394-4470-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1418179394-4470-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: makita.toshiaki@lab.ntt.co.jp
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1418179394-4470-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
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

From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date: Wed, 10 Dec 2014 11:43:14 +0900

> -	features &= ~NETIF_F_ONE_FOR_ALL;
> +	features &= ~NETIF_F_ONE_FOR_ALL | NETIF_F_GSO_SOFTWARE;

I don't think this is the expression you intend to use.

I think you meant:

	features &= ~(NETIF_F_ONE_FOR_ALL | NETIF_F_GSO_SOFTWARE);

Or:

	features = ~NETIF_F_ONE_FOR_ALL;
	features |= NETIF_F_GSO_SOFTWARE;
