From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 05 Dec 2016 23:55:28 +0100
Message-ID: <5845F060.2050700@iogearbox.net>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37539 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbcLEWza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 17:55:30 -0500
In-Reply-To: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem,

On 12/05/2016 09:28 PM, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Add support for attaching an eBPF object by file descriptor.
>
> The iptables binary can be called with a path to an elf object or a
> pinned bpf object. Also pass the mode and path to the kernel to be
> able to return it later for iptables dump and save.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

just out of pure curiosity, use case is for android guys wrt
accounting, or anything specific that cls_bpf on tc ingress +
egress cannot do already?

Thanks,
Daniel
