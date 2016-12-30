From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/2] bpf: add longest prefix match map
Date: Fri, 30 Dec 2016 15:25:36 -0500 (EST)
Message-ID: <20161230.152536.1044375840168125040.davem@davemloft.net>
References: <20161229172855.14910-1-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46074 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753499AbcL3UZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 15:25:38 -0500
In-Reply-To: <20161229172855.14910-1-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Thu, 29 Dec 2016 18:28:53 +0100

> This patch set adds a longest prefix match algorithm that can be used
> to match IP addresses to a stored set of ranges. It is exposed as a
> bpf map type.
>    
> Internally, data is stored in an unbalanced tree of nodes that has a
> maximum height of n, where n is the prefixlen the trie was created
> with.
>  
> Not that this has nothing to do with fib or fib6 and is in no way meant
> to replace or share code with it. It's rather a much simpler
> implementation that is specifically written with bpf maps in mind.
>  
> Patch 1/2 adds the implementation, and 2/2 an extensive test suite.
>  
> Feedback is much appreciated.

I'll give Alexei and Daniel time to provide feedback on this series.
