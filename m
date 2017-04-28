From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Misc BPF updates
Date: Fri, 28 Apr 2017 15:49:37 -0400 (EDT)
Message-ID: <20170428.154937.2176816745018007393.davem@davemloft.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035210AbdD1Ttj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 15:49:39 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 27 Apr 2017 01:39:30 +0200

> This set cleans up ldimm64 leftovers from early eBPF days and
> adds couple of test cases related to this to the verifier test
> suite. It also cleans up the kallsyms spinlock (had same patch
> also in queue) by relaxing it through switching to _bh variant.
> It fixes up test_progs in relation to htons/ntohs and adds
> accessor macros for the percpu tests in test_maps.

Series applied, thanks for fixing all of this stuff.
