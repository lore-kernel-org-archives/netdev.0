From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ether_addr_equal: Optimize implementation,
 remove unused compare_ether_addr
Date: Fri, 06 Dec 2013 16:37:58 -0500 (EST)
Message-ID: <20131206.163758.1360809557088338617.davem@davemloft.net>
References: <34a0bad292ab2535a3a2e757a83eca13408e55b7.1386283991.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@landley.net, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <34a0bad292ab2535a3a2e757a83eca13408e55b7.1386283991.git.joe@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu,  5 Dec 2013 14:54:38 -0800

> Add a new check for CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to reduce
> the number of or's used in the ether_addr_equal comparison to very
> slightly improve function performance.
> 
> Simplify the ether_addr_equal_64bits implementation.
> Integrate and remove the zap_last_2bytes helper as it's now
> used only once.
> 
> Remove the now unused compare_ether_addr function.
> 
> Update the unaligned-memory-access documentation to remove the
> compare_ether_addr description and show how unaligned accesses
> could occur with ether_addr_equal.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
