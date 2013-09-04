From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] llc: Use normal etherdevice.h tests
Date: Tue, 03 Sep 2013 22:34:59 -0400 (EDT)
Message-ID: <20130903.223459.300009956806963697.davem@davemloft.net>
References: <1378066315.1953.23.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378066315.1953.23.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 01 Sep 2013 13:11:55 -0700

> Convert the llc_<foo> static inlines to the
> equivalents from etherdevice.h and remove
> the llc_<foo> static inline functions.
> 
> llc_mac_null -> is_zero_ether_addr
> llc_mac_multicast -> is_multicast_ether_addr
> llc_mac_match -> ether_addr_equal
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
