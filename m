From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] tcp: more reliable window probes
Date: Sat, 09 May 2015 16:42:54 -0400 (EDT)
Message-ID: <20150509.164254.1317151052707636957.davem@davemloft.net>
References: <1430947585-2375-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	nanditad@google.com, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45321 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbbEIUnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:43:07 -0400
In-Reply-To: <1430947585-2375-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed,  6 May 2015 14:26:23 -0700

> This series address a problem caused by small rto_min timers in DC,
> leading to either timer storms or early flow terminations.
> 
> We also add two new SNMP counters for proper monitoring :
> TCPWinProbe and TCPKeepAlive
> 
> v2: added TCPKeepAlive counter, as suggested by Yuchung & Neal

Series applied, thanks Eric.
