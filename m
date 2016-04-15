From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] tcp: final work on SYNFLOOD behavior
Date: Fri, 15 Apr 2016 16:46:13 -0400 (EDT)
Message-ID: <20160415.164613.240856722381350785.davem@davemloft.net>
References: <1460610340-22163-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52146 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbcDOUqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 16:46:15 -0400
In-Reply-To: <1460610340-22163-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Wed, 13 Apr 2016 22:05:38 -0700

> In the first patch, I remove the costly association of SYNACK+COOKIES
> to a listener. I believe other parts of the stack should be ready.
> 
> The second patch removes a useless write into listener socket
> in tcp_rcv_state_process(), incurring false sharing in
> tcp_conn_request()
> 
> Performance under SYNFLOOD goes from 3.2 Mpps to 6 Mpps.

Geese, you almost make it look too easy....

> Test was using a single TCP listener, on a host with 8 RX queues
> on the NIC, and 24 cores (48 ht)

Looks good, series applied, thanks Eric.
