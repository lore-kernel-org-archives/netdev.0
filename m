From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/9] bpf: add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed, 09 Aug 2017 09:55:53 -0700 (PDT)
Message-ID: <20170809.095553.268665355274669790.davem@davemloft.net>
References: <cover.1502272924.git.daniel@iogearbox.net>
        <cover.1502272924.git.daniel@iogearbox.net>
        <63b41a38e0d58536700c999ade7c2c267bd2613d.1502272924.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754462AbdHIQzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:55:54 -0400
In-Reply-To: <63b41a38e0d58536700c999ade7c2c267bd2613d.1502272924.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  9 Aug 2017 12:23:53 +0200

>   [1] https://github.com/borkmann/llvm/tree/bpf-insns

How is this "backwards compatible"?

If someone takes a new LLVM and tries to load those programs
into an older kernel they will be rejected.

There appears to be no effort to make things work cleanly in
that situation at all.
