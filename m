From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/9] bpf: fix stack_depth usage by test_bpf.ko
Date: Wed, 31 May 2017 14:15:02 -0400 (EDT)
Message-ID: <20170531.141502.1137764740674039078.davem@davemloft.net>
References: <20170530203135.3642768-1-ast@fb.com>
        <20170530203135.3642768-7-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, kernel-team@fb.com
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751093AbdEaSPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:15:04 -0400
In-Reply-To: <20170530203135.3642768-7-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 30 May 2017 13:31:32 -0700

> test_bpf.ko doesn't call verifier before selecting interpreter or JITing,
> hence the tests need to manually specify the amount of stack they consume.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I do not like this and the previous patch, it seems so error prone.
