From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/5] packet fixes
Date: Sun, 15 Nov 2015 18:01:44 -0500 (EST)
Message-ID: <20151115.180144.569374750493313448.davem@davemloft.net>
References: <cover.1447278504.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, willemb@google.com, tklauser@distanz.ch,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbbKOXBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 18:01:49 -0500
In-Reply-To: <cover.1447278504.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 11 Nov 2015 23:25:39 +0100

> Fixes a couple of issues in packet sockets, i.e. on TX ring side. See
> individual patches for details.
> 
> v2 -> v3:
>  - First two patches unchanged, kept Jason's Ack
>  - Reworked 3rd patch and split into 3:
>   - check for dev type as discussed with Willem
>   - infer skb->protocol
>   - fix max len for dgram
> v1 -> v2:
>  - Added patch 2 as suggested by Dave
>  - Rest is unchanged from previous submission

Series applied and queued up for -stable, thanks.
