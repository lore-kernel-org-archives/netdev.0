From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fix CONFIG_NET_NS=n compilation
Date: Wed, 11 Mar 2015 23:29:40 -0400 (EDT)
Message-ID: <20150311.232940.1345045254716776224.davem@davemloft.net>
References: <20150311.215553.1544350193194225837.davem@davemloft.net>
	<1426128863.11398.135.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com, ebiederm@xmission.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbbCLD3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:29:42 -0400
In-Reply-To: <1426130872.11398.141.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Mar 2015 20:27:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> I forgot to use write_pnet() in three locations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 33cf7c90fe2f9 ("net: add real socket cookies")
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied, thanks Eric.
