From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: log autoconfiguration failures
Date: Tue, 10 Dec 2013 22:16:13 -0500 (EST)
Message-ID: <20131210.221613.1663906151846555561.davem@davemloft.net>
References: <1386606408-21552-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, jpirko@redhat.com
To: dvlasenk@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386606408-21552-1-git-send-email-dvlasenk@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denys Vlasenko <dvlasenk@redhat.com>
Date: Mon,  9 Dec 2013 17:26:48 +0100

> If ipv6 auto-configuration does not work, currently it's hard
> to track what's going on. This change adds log messages
> (at debug level) on every code path where ipv6 autoconf fails.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>

Add statistics, those are more globally useful.

> +		pr_debug("IPv6 addrconf: %s: address length %d != %s\n",
> +				dev->name, dev->addr_len, "ETH_ALEN");

And this is not indented correctly, the arguments on lines after the
first must line up exactly to the column after the openning parenthesis
of the function call.

The idea isn't to use just TABs until you think it looks nice, rather
you should use the appropriate number of SPACE and TAB characters
necessary to reach the exact column.
