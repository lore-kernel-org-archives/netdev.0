From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Preserve const register type on const OR
 alu ops
Date: Sun, 04 Dec 2016 00:41:59 +0100
Message-ID: <58435847.2000406@iogearbox.net>
References: <1480797093-1050393-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gianluca Borello <g.borello@gmail.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46484 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751608AbcLCXmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 18:42:18 -0500
In-Reply-To: <1480797093-1050393-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2016 09:31 PM, Alexei Starovoitov wrote:
> From: Gianluca Borello <g.borello@gmail.com>
>
> Occasionally, clang (e.g. version 3.8.1) translates a sum between two
> constant operands using a BPF_OR instead of a BPF_ADD. The verifier is
> currently not handling this scenario, and the destination register type
> becomes UNKNOWN_VALUE even if it's still storing a constant. As a result,
> the destination register cannot be used as argument to a helper function
> expecting a ARG_CONST_STACK_*, limiting some use cases.
>
> Modify the verifier to handle this case, and add a few tests to make sure
> all combinations are supported, and stack boundaries are still verified
> even with BPF_OR.
>
> Signed-off-by: Gianluca Borello <g.borello@gmail.com>
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
