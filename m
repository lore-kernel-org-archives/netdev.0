From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/4] net: ipv6: Unify {raw,udp}6_sock_seq_show.
Date: Tue, 04 Jun 2013 12:56:55 -0700 (PDT)
Message-ID: <20130604.125655.432082878834093167.davem@davemloft.net>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	<1370048750-28441-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3FDT4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 15:56:55 -0400
In-Reply-To: <1370048750-28441-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Sat,  1 Jun 2013 10:05:48 +0900

> udp6_sock_seq_show and raw6_sock_seq_show are identical, except
> the UDP version displays ports and the raw version displays the
> protocol. Refactor most of the code in these two functions into
> a new common ip6_dgram_sock_seq_show function, in preparation
> for using it to display ICMPv6 sockets as well.
> 
> Also reduce the indentation in parts of include/net/transp_v6.h
> to improve readability.
> 
> Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
