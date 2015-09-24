From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: byte swap rss_key to comply to Toeplitz
 specs
Date: Thu, 24 Sep 2015 14:35:13 -0700 (PDT)
Message-ID: <20150924.143513.1872188467000379622.davem@davemloft.net>
References: <20150922.160644.138485112664023430.davem@davemloft.net>
	<1442964885.29850.100.camel@edumazet-glaptop2.roam.corp.google.com>
	<1442966698.29850.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753309AbbIXVfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 17:35:15 -0400
In-Reply-To: <1442966698.29850.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 22 Sep 2015 17:04:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After a good amount of debugging, I found bnx2x was byte swaping
> the 40 bytes of rss_key.
> 
> If we byte swap the key, then bnx2x generates hashes matching
> MSDN specs as documented in (Verifying the RSS Hash Calculation)
> 
> https://msdn.microsoft.com/en-us/library/windows/hardware/ff571021%
> 28v=vs.85%29.aspx
> 
> It is mostly a non issue, unless we want to mix different NIC
> in a host, and want consistent hashing among all of them, ie
> if they all use the boot time generated rss key, or if some application
> is choosing specific tuple(s) so that incoming traffic lands into known
> rx queue(s).
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
