From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selftests/bpf: fix broken build
Date: Sun, 12 Mar 2017 23:48:54 -0700 (PDT)
Message-ID: <20170312.234854.2051066183598409902.davem@davemloft.net>
References: <1489212355-3289694-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, shuah@kernel.org, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54340 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdCMGsz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:48:55 -0400
In-Reply-To: <1489212355-3289694-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Fri, 10 Mar 2017 22:05:55 -0800

> Recent merge of 'linux-kselftest-4.11-rc1' tree broke bpf test build.
> None of the tests were building and test_verifier.c had tons of compiler errors.
> Fix it and add #ifdef CAP_IS_SUPPORTED to support old versions of libcap.
> Tested on centos 6.8 and 7
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks.
