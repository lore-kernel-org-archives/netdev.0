From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] x86: bpf_jit_comp: secure bpf jit against spraying
 attacks
Date: Sun, 19 May 2013 19:02:46 +0200
Message-ID: <519905B6.3080101@redhat.com>
References: <1368844623.3301.142.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab3ESRDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 May 2013 13:03:00 -0400
In-Reply-To: <1368844623.3301.142.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2013 04:37 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> hpa bringed into my attention some security related issues
> with BPF JIT on x86.
>
> This patch makes sure the bpf generated code is marked read only,
> as other kernel text sections.
>
> It also splits the unused space (we vmalloc() and only use a fraction of
> the page) in two parts, so that the generated bpf code not starts at a
> known offset in the page, but a pseudo random one.
>
> Refs:
> http://mainisusuallyafunction.blogspot.com/2012/11/attacking-hardened-linux-systems-with.html
>
> Reported-by: H. Peter Anvin <hpa@zytor.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Great work !

Probably other archs could later on follow-up with setting to read-only, too.

Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
