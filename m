From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: mv643xx_eth: remove deprecated inet_lro support
Date: Fri, 12 Apr 2013 05:55:39 -0700
Message-ID: <1365771339.4459.0.camel@edumazet-glaptop>
References: <1365707488-28819-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <1365758400-12565-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Florian Fainelli <florian@openwrt.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Dale Farnsworth <dale@farnsworth.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Soeren Moch <smoch@web.de>, Willy Tarreau <w@1wt.eu>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365758400-12565-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-04-12 at 11:20 +0200, Sebastian Hesselbarth wrote:
> With recent support for GRO, there is no need to keep both LRO and
> GRO. This patch therefore removes the deprecated inet_lro support
> from mv643xx_eth. This is work is based on an experimental patch
> provided by Eric Dumazet and Willy Tarreau.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Based-on-patch-by: Eric Dumazet <eric.dumazet@gmail.com>
> Based-on-patch-by: Willy Tarreau <w@1wt.eu>
> ---
> Changes from v1:
> - also remove INET_LRO from Kconfig (Reported by Eric Dumazet)

Thanks for finishing this patch

Signed-off-by: Eric Dumazet <edumazet@google.com>
