From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 3/5] selftests/bpf: add a test for a pruning
 bug in the verifier
Date: Wed, 23 Aug 2017 16:43:46 +0200
Message-ID: <599D94A2.8000903@iogearbox.net>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com> <bbfb3545-abbd-9c9d-1632-64804d1b7cc2@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Edward Cree <ecree@solarflare.com>, davem@davemloft.net,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45410 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754107AbdHWOnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:43:53 -0400
In-Reply-To: <bbfb3545-abbd-9c9d-1632-64804d1b7cc2@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2017 04:10 PM, Edward Cree wrote:
> From: Alexei Starovoitov <ast@fb.com>
>
> The test makes a read through a map value pointer, then considers pruning
>   a branch where the register holds an adjusted map value pointer.  It
>   should not prune, but currently it does.
>
> Signed-off-by: Alexei Starovoitov <ast@fb.com>
> [ecree@solarflare.com: added test-name and patch description]
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
