From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] samples/bpf: silence compiler warnings
Date: Sat, 03 Dec 2016 16:01:24 -0500 (EST)
Message-ID: <20161203.160124.1258832542719088253.davem@davemloft.net>
References: <1480645872-999847-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751296AbcLCVBZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 16:01:25 -0500
In-Reply-To: <1480645872-999847-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Thu, 1 Dec 2016 18:31:12 -0800

> silence some of the clang compiler warnings like:
> include/linux/fs.h:2693:9: warning: comparison of unsigned enum expression < 0 is always false
> arch/x86/include/asm/processor.h:491:30: warning: taking address of packed member 'sp0' of class or structure 'x86_hw_tss' may result in an unaligned pointer value
> include/linux/cgroup-defs.h:326:16: warning: field 'cgrp' with variable sized type 'struct cgroup' not at the end of a struct or class is a GNU extension
> since they add too much noise to samples/bpf/ build.
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
