From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] bridge: Use ether_addr_copy and ETH_ALEN
Date: Mon, 24 Feb 2014 19:16:55 -0500 (EST)
Message-ID: <20140224.191655.402406764181553805.davem@davemloft.net>
References: <06d3e7e463c2bbfa8b5264e67daace1181ada090.1393142669.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <06d3e7e463c2bbfa8b5264e67daace1181ada090.1393142669.git.joe@perches.com>
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

From: Joe Perches <joe@perches.com>
Date: Sun, 23 Feb 2014 00:05:25 -0800

> Convert the more obvious uses of memcpy to ether_addr_copy.
> 
> There are still uses of memcpy that could be converted but
> these addresses are __aligned(2).
> 
> Convert a couple uses of 6 in gr_private.h to ETH_ALEN.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
