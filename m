From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/5] bpf: Add verifier test case for alignment.
Date: Thu, 11 May 2017 15:01:14 +0200
Message-ID: <5914609A.9040709@iogearbox.net>
References: <20170510.151005.805363538289965960.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48641 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754733AbdEKNBn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 09:01:43 -0400
In-Reply-To: <20170510.151005.805363538289965960.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 09:10 PM, David Miller wrote:
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks for all the tests! Did you check whether it also allows
to lift some of the F_NEEDS_EFFICIENT_UNALIGNED_ACCESS flagged
tests in test_verifier? I think we should now be able to rework
that a bit, but not subject to this patch set, of course.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
