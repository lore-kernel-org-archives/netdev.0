From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: boot test failure (net tree)
Date: Tue, 16 Aug 2011 17:15:25 -0700 (PDT)
Message-ID: <20110816.171525.639251389938336183.davem@davemloft.net>
References: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110817100146.3b557cf815a5a2ae09bc09a7@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 17 Aug 2011 10:01:46 +1000

> In particular, CONFIG_TIGON3 newly depends on
> CONFIG_NET_VENDOR_BROADCOM which will no be selected when doing a
> "make oldconfig" from a working config.

When you type "make oldconfig" with an existing .config it prompts you
for those vendor guards, giving you ample opportunity to say yes to
them.
