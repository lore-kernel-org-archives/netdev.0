From: David Miller <davem@davemloft.net>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 04 Apr 2012 05:25:05 -0400 (EDT)
Message-ID: <20120404.052505.230288445505560474.davem@davemloft.net>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org
To: slash@ac.auone-net.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Date: Wed, 4 Apr 2012 18:03:11 +0900

> Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
> Move the sock_ code to net/core/"), ss command from iproute package
> doesn't work if INET_DIAG is not enabled.

Well, of course you need to enable that Kconfig options to get
netlink socket dumping support for inet protocols.
