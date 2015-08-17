From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] packet: add cBPF and eBPF fanout modes
Date: Mon, 17 Aug 2015 14:23:13 -0700 (PDT)
Message-ID: <20150817.142313.1118336177187820064.davem@davemloft.net>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, daniel@iogearbox.net,
	ast@plumgrid.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbbHQVXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:23:15 -0400
In-Reply-To: <1439605897-28311-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Fri, 14 Aug 2015 22:31:33 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Allow programmable fanout modes. Support both classical BPF programs
> passed directly and extended BPF programs passed by file descriptor.
> 
> One use case is packet steering by deep packet inspection, for
> instance for packet steering by application layer header fields.
> 
> Separate the configuration of the fanout mode and the configuration
> of the program, to allow dynamic updates to the latter at runtime.
> 
> Changes
>   v1 -> v2:
>     - follow SO_LOCK_FILTER semantics on filter updates
>     - only accept eBPF programs of type BPF_PROG_TYPE_SOCKET_FILTER
>     - rename PACKET_FANOUT_BPF to PACKET_FANOUT_CBPF to match
>       man 2 bpf usage: "classic" vs. "extended" BPF.

Series applied, although I hope that synchronize_net() doesn't become
a scalability issue in some workload in the future.
