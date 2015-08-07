From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 0/3] CPSW interrupt handling cleanup and
 performance improvement
Date: Thu, 06 Aug 2015 21:59:42 -0700 (PDT)
Message-ID: <20150806.215942.584527396997569340.davem@davemloft.net>
References: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbbHGE7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 00:59:43 -0400
In-Reply-To: <1438684580-11384-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 4 Aug 2015 16:06:17 +0530

> This patch series removes the irq controller disable interrupt and
> adding a napi for tx event handling which improves the performance by
> ~180Mbps on dra7-evm
> 
> [  5] local 192.168.10.116 port 5001 connected with 192.168.10.165 port 44176
> [  5]  0.0-60.0 sec  1.48 GBytes   210 Mbits/sec
> [  4] local 192.168.10.116 port 5001 connected with 192.168.10.165 port 33257
> [  4]  0.0-60.0 sec  2.71 GBytes   386 Mbits/sec
> 
> Changes from initial version: 
> * Added a patch to have napi only for first interface as there is
>   no use of having seperate napis for each interface as the
>   interrupt is shared by both interface and only one napi is
>   scheduled for each interrupt.

Series applied, thanks.
