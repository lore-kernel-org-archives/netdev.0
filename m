From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] qede: Fix net-next "make ARCH=x86_64"
Date: Thu, 10 Mar 2016 16:19:43 -0500 (EST)
Message-ID: <20160310.161943.1520841961288028312.davem@davemloft.net>
References: <1457428184-18336-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216AbcCJVTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 16:19:44 -0500
In-Reply-To: <1457428184-18336-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 8 Mar 2016 04:09:44 -0500

> 'commit 55482edc25f0606851de42e73618f813f310d009
> ("qede: Add slowpath/fastpath support and enable hardware GRO")'
> introduces below error when compiling net-next with "make ARCH=x86_64"
> 
> drivers/built-in.o: In function `qede_rx_int':
> qede_main.c:(.text+0x6101a0): undefined reference to `tcp_gro_complete'
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied, thank you.
