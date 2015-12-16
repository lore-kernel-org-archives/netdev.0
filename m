From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] inet: tcp: fix inetpeer_set_addr_v4()
Date: Wed, 16 Dec 2015 00:14:35 -0500 (EST)
Message-ID: <20151216.001435.1872718804742060388.davem@davemloft.net>
References: <1450241804.8474.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com, ycheng@google.com,
	ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732AbbLPFOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 00:14:39 -0500
In-Reply-To: <1450241804.8474.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Dec 2015 20:56:44 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> David Ahern added a vif field in the a4 part of inetpeer_addr struct.
> 
> This broke IPv4 TCP fast open client side and more generally tcp metrics
> cache, because inetpeer_addr_cmp() is now comparing two u32 instead of
> one.
> 
> inetpeer_set_addr_v4() needs to properly init vif field, otherwise
> the comparison result depends on uninitialized data.
> 
> Fixes: 192132b9a034 ("net: Add support for VRFs to inetpeer cache")
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks Eric.
