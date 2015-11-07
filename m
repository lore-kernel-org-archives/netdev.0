From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] packet: do skb_probe_transport_header when we
 actually have data
Date: Sat, 07 Nov 2015 13:35:02 -0500 (EST)
Message-ID: <20151107.133502.833614670001999282.davem@davemloft.net>
References: <cover.1446842228.git.daniel@iogearbox.net>
	<5cdcd969eec9228a18c0dc54f9cc4b7b6b07ce05.1446842228.git.daniel@iogearbox.net>
	<1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, edumazet@google.com, willemb@google.com,
	tklauser@distanz.ch, netdev@vger.kernel.org, jasowang@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608AbbKGSfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 13:35:05 -0500
In-Reply-To: <1446900176.17135.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 07 Nov 2015 04:42:56 -0800

> The if (!packet_use_direct_xmit(po)) test looks dubious.
> 
> Setting transport header has nothing to do with bypassing qdisc ?
> 
> This might lead to hard to debug problems, for drivers expecting
> transport header being set ?

Do we have any such drivers that need it in this scenerio?
