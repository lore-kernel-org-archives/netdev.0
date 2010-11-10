From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 RESEND] net: packet: fix information leak to
 userland
Date: Wed, 10 Nov 2010 12:09:21 -0800 (PST)
Message-ID: <20101110.120921.246514765.davem@davemloft.net>
References: <1289413760-12510-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, jpirko@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: segooon@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289413760-12510-1-git-send-email-segooon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segooon@gmail.com>
Date: Wed, 10 Nov 2010 21:29:18 +0300

> packet_getname_spkt() doesn't initialize all members of sa_data field of
> sockaddr struct if strlen(dev->name) < 13.  This structure is then copied
> to userland.  It leads to leaking of contents of kernel stack memory.
> We have to fully fill sa_data with strncpy() instead of strlcpy().
> 
> The same with packet_getname(): it doesn't initialize sll_pkttype field of
> sockaddr_ll.  Set it to zero.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Applied.
