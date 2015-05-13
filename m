From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/6] refine rollover
Date: Wed, 13 May 2015 15:43:23 -0400 (EDT)
Message-ID: <20150513.154323.1473288790736699712.davem@davemloft.net>
References: <1431446210-13286-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	david.laight@aculab.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbbEMTn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 15:43:26 -0400
In-Reply-To: <1431446210-13286-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Tue, 12 May 2015 11:56:44 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> refine packet socket rollover:
> 
> 1. mitigate a case of lock contention
> 2. avoid exporting resource exhaustion to other sockets,
>    by migrating only to a victim socket that has ample room
> 3. avoid reordering of most flows on the socket,
>    by migrating first the flow responsible for load imbalance
> 4. help processes detect load imbalance,
>    by exporting rollover counters
> 
> Context: rollover implements flow migration in packet socket fanout
> groups in case of extreme load imbalance. It is a specific
> implementation of migration that minimizes reordering by selecting
> the same victim socket when possible (and by selecting subsequent
> victims in a round robin fashion, from which its name derives).

The user API looks a lot better now, series applied, thanks Willem.
