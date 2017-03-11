From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] selftests/bpf: fix broken build
Date: Sat, 11 Mar 2017 12:59:46 +0100
Message-ID: <58C3E6B2.7010301@iogearbox.net>
References: <1489212355-3289694-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48059 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755432AbdCKL7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 06:59:53 -0500
In-Reply-To: <1489212355-3289694-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2017 07:05 AM, Alexei Starovoitov wrote:
> Recent merge of 'linux-kselftest-4.11-rc1' tree broke bpf test build.
> None of the tests were building and test_verifier.c had tons of compiler errors.
> Fix it and add #ifdef CAP_IS_SUPPORTED to support old versions of libcap.
> Tested on centos 6.8 and 7
>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Fix looks correct to me and makes the test suite work again.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Tested-by: Daniel Borkmann <daniel@iogearbox.net>
