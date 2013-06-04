From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/4] net: ipv4: make the ping /proc code
 AF-independent
Date: Tue, 04 Jun 2013 12:57:00 -0700 (PDT)
Message-ID: <20130604.125700.17888231777343434.davem@davemloft.net>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	<1370048750-28441-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57980 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab3FDT5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 15:57:01 -0400
In-Reply-To: <1370048750-28441-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Sat,  1 Jun 2013 10:05:49 +0900

> Introduce a ping_seq_afinfo structure (similar to its UDP
> equivalent) and use it to make some of the ping /proc functions
> address-family independent. Rename the remaining ping /proc
> functions from ping_* to ping_v4_*.
> 
> Compiles and displays reasonable results with CONFIG_IPV6={n,m,y}
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
