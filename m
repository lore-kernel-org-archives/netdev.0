From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Sun, 01 Apr 2012 23:19:54 -0400 (EDT)
Message-ID: <20120401.231954.992963391252108626.davem@davemloft.net>
References: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, pablo@netfilter.org, eric.dumazet@gmail.com,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333336250-4110-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>
Date: Mon,  2 Apr 2012 11:10:50 +0800

> We should check the length of the data before dereferencing it when parsing
> the TCP options.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Proper Subject prefix here would be "tcp: ", not "net: "
and maybe adjust the subject line to also mention the
specific function being fixed, which in this case would
be tcp_parse_options().  So:

	tcp: Validate length of data before dereference in tcp_parse_options().

and then you can make the commit message just be your signoff.

