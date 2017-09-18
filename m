From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] bpf: devmap: pass on return value of bpf_map_precharge_memlock
Date: Mon, 18 Sep 2017 15:14:01 +0200
Message-ID: <59BFC699.1060009@iogearbox.net>
References: <20170918130346.10833-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>,
        Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39151 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbdIRNOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 09:14:05 -0400
In-Reply-To: <20170918130346.10833-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 03:03 PM, Tobias Klauser wrote:
> If bpf_map_precharge_memlock in dev_map_alloc, -ENOMEM is returned
> regardless of the actual error produced by bpf_map_precharge_memlock.
> Fix it by passing on the error returned by bpf_map_precharge_memlock.
>
> Also return -EINVAL instead of -ENOMEM if the page count overflow check
> fails.
>
> This makes dev_map_alloc match the behavior of other bpf maps' alloc
> functions wrt. return values.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

(This would then need to go via net tree.)

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
