From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4: replace simple_strtoul with kstrtoul
Date: Sun, 20 May 2012 04:07:20 -0400 (EDT)
Message-ID: <20120520.040720.43599161769776729.davem@davemloft.net>
References: <1337472798-18913-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eldad@fogrefinery.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337472798-18913-1-git-send-email-eldad@fogrefinery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eldad Zack <eldad@fogrefinery.com>
Date: Sun, 20 May 2012 02:13:18 +0200

> Replace simple_strtoul with kstrtoul in three similar occurrences, all setup
> handlers:
> * route.c: set_rhash_entries
> * tcp.c: set_thash_entries
> * udp.c: set_uhash_entries
> 
> Also check if the conversion failed.
> 
> Signed-off-by: Eldad Zack <eldad@fogrefinery.com>

Applied.
