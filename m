From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Wed, 03 May 2017 09:52:51 -0400 (EDT)
Message-ID: <20170503.095251.353611409224180200.davem@davemloft.net>
References: <20170503041443.3125777-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752080AbdECNw5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:52:57 -0400
In-Reply-To: <20170503041443.3125777-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 2 May 2017 21:14:43 -0700

> -D__x86_64__ workaround was used to make /usr/include/features.h
> to follow expected path through the system include headers.
> This is not portable.
> Instead define dummy stubs.h which is used by 'clang -target bpf'
> 
> Fixes: 6882804c916b ("selftests/bpf: add a test for overlapping packet range checks")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks for getting rid of this wart.
