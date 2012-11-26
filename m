From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Mon, 26 Nov 2012 17:37:14 -0500 (EST)
Message-ID: <20121126.173714.1141101687172076447.davem@davemloft.net>
References: <50AC9CF6.2020501@asianux.com>
	<1353872669.30446.863.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gang.chen@asianux.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55096 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2KZWhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 17:37:18 -0500
In-Reply-To: <1353872669.30446.863.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 25 Nov 2012 11:44:29 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Name of pimreg devices are built from following format :
> 
> char name[IFNAMSIZ]; // IFNAMSIZ == 16
> 
> sprintf(name, "pimreg%u", mrt->id);
> 
> We must therefore limit mrt->id to 9 decimal digits
> or risk a buffer overflow and a crash.
> 
> Restrict table identifiers in [0 ... 999999999] interval.
> 
> Reported-by: Chen Gang <gang.chen@asianux.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
