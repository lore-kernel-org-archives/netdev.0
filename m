From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c V2
Date: Thu, 22 May 2008 21:22:46 +0200
Message-ID: <4835C806.6020408@trash.net>
References: <Pine.LNX.4.64.0805222145320.6071@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com, clameter@sgi.com
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg wrote:
> To: kaber@trash.net
> [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c V2
> From: Pekka Enberg <penberg@cs.helsinki.fi>
>
> The ksize() API is going away because it is being abused and it doesn't even
> work consistenly across different allocators. Therefore, convert
> net/netfilter/nf_conntrack_extend.c to use krealloc().
>
> Cc: <netfilter-devel@vger.kernel.org>
> Cc: <netdev@vger.kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
> ---
> Patrick, please use this patch instead. The previous one did the moving
> unconditionally which is wrong. This one moves entries around only if
> krealloc() allocated a new buffer.

Applied, thanks.
