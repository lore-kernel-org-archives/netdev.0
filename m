From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Add complementary BPF conditional jump
 instructions
Date: Mon, 31 Dec 2012 14:37:15 -0800 (PST)
Message-ID: <20121231.143715.1238174487756359071.davem@davemloft.net>
References: <cover.1356960070.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab2LaWhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 17:37:16 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 31 Dec 2012 14:59:40 +0100

> This set adds adds jump operations for lt (<), le (<=), ne (!=) that
> compare A with K resp. X in order to facilitate filter programming
> with conditional jumps, as also available in McCanne et. al's BPF+
> paper (``BPF+: Exploiting Global Data-flow Optimization in a Generalized
> Packet Filter Architecture'').
> 
> Also, follow-up BPF JIT implementations for x86, Sparc and PowerPC
> are added in this set.

Whilst I agree that adding NE jumps adds great value and closes a
serious gap, the rest can be synthesized by simply swapping the
arguments and using a comparison that does already exist.

Why isn't that sufficient?
