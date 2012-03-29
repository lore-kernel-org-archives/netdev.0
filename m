From: David Miller <davem@davemloft.net>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 03:49:57 -0400 (EDT)
Message-ID: <20120329.034957.655153582806618222.davem@davemloft.net>
References: <20120329074443.GB2098@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab2C2HuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 03:50:06 -0400
In-Reply-To: <20120329074443.GB2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 29 Mar 2012 09:44:43 +0200

> Here are proposed things to be done:
> 1) introduce in-kernel api for creating sk-unattached filters (I have
>    the patch cooked up already)
> 
> 2) extend current BPF machine to allow XOR operation. Not sure if this
>    is doable or what the best of doing this is.
> 
> 3) add possibility to pass some data to the machine via
>    pre-filling "Scratch Memory Store". I think this can be done easily
>    moving "u32 mem[BPF_MEMWORDS];" to bpf_func caller and pass it as the
>    second function parameter. That should not break anything.
> 
> Then the computed hash can be either stored into Scratch memory or returned
> directly (where ordinary sk filters return len).
> 
> Does this seems reasonable? Thoughts, comments?

No fundamental objections, but we have all of these JITs now to
update when adding new operations or semantics, so be careful.
