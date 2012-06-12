From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] netfilter: add user-space connection tracking
 helper infrastructure
Date: Tue, 12 Jun 2012 15:46:49 -0700 (PDT)
Message-ID: <20120612.154649.2161893246735218280.davem@davemloft.net>
References: <1339524380-2707-1-git-send-email-pablo@netfilter.org>
	<1339524380-2707-8-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339524380-2707-8-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue, 12 Jun 2012 20:06:20 +0200

> +	pr_info("nfnl_cthelper: registering with nfnetlink.\n");
 ...
> +	pr_info("nfnl_cthelper: unregistering from nfnetlink.\n");

These messages are fine during development, but not for the copy you
actually finally commit into your tree :-)
