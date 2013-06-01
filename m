From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] net: ipv6: Unify {raw,udp}6_sock_seq_show.
Date: Fri, 31 May 2013 17:01:13 -0700 (PDT)
Message-ID: <20130531.170113.626875599168962007.davem@davemloft.net>
References: <ko3rsc@ger.gmane.org>
	<1369806459-26901-1-git-send-email-lorenzo@google.com>
	<1369806459-26901-2-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053Ab3FAABO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:01:14 -0400
In-Reply-To: <1369806459-26901-2-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 29 May 2013 14:47:37 +0900

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

Do not mix functional changes with unrelated whitespace and other cleanups.

Split this patch series up properly and resubmit this entire series.
