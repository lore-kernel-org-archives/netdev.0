From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Silence seq_scale() unused warning
Date: Tue, 06 Dec 2011 00:31:57 -0500 (EST)
Message-ID: <20111206.003157.159978113328078893.davem@davemloft.net>
References: <1323109796-31084-1-git-send-email-sboyd@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: sboyd@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1323109796-31084-1-git-send-email-sboyd@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Boyd <sboyd@codeaurora.org>
Date: Mon,  5 Dec 2011 10:29:56 -0800

> On a CONFIG_NET=y build
> 
> net/core/secure_seq.c:22: warning: 'seq_scale' defined but not
> used
> 
> Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
> ---
> 
> I don't know how realistic this configuration is, but here it goes.

Just test INET all by itself, IPV6 will always need the INET
infrastructure for hash tables and inet socket management even in the
extremely unlikely event that we make ipv4 independently selectable at
some point.
