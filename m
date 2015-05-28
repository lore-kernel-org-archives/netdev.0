From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: allow BPF programs access skb->skb_iif
 and skb->dev->ifindex fields
Date: Thu, 28 May 2015 21:22:34 +0200
Message-ID: <55676AFA.2030403@iogearbox.net>
References: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52723 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbbE1TWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 15:22:43 -0400
In-Reply-To: <1432765839-7709-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 12:30 AM, Alexei Starovoitov wrote:
> classic BPF already exposes skb->dev->ifindex via SKF_AD_IFINDEX extension.
> Allow eBPF program to access it as well. Note that classic aborts execution
> of the program if 'skb->dev == NULL' (which is inconvenient for program
> writers), whereas eBPF returns zero in such case.

That's better, yep.

> Also expose the 'skb_iif' field, since programs triggered by redirected
> packet need to known the original interface index.
> Summary:
> __skb->ifindex         -> skb->dev->ifindex
> __skb->ingress_ifindex -> skb->skb_iif
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
