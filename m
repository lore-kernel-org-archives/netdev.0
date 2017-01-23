From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 0/3] bpf: add longest prefix match map
Date: Mon, 23 Jan 2017 16:11:02 -0500 (EST)
Message-ID: <20170123.161102.1338660110746497238.davem@davemloft.net>
References: <20170121162613.4159-1-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750957AbdAWVLH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:11:07 -0500
In-Reply-To: <20170121162613.4159-1-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Sat, 21 Jan 2017 17:26:10 +0100

> This patch set adds a longest prefix match algorithm that can be used
> to match IP addresses to a stored set of ranges. It is exposed as a
> bpf map type.
>    
> Internally, data is stored in an unbalanced tree of nodes that has a
> maximum height of n, where n is the prefixlen the trie was created
> with.
>  
> Note that this has nothing to do with fib or fib6 and is in no way meant
> to replace or share code with it. It's rather a much simpler
> implementation that is specifically written with bpf maps in mind.
>  
> Patch 1/2 adds the implementation, 2/2 an extensive test suite and 3/3
> has benchmarking code for the new trie type.
> 
> Feedback is much appreciated.

Series applied, thank you.
