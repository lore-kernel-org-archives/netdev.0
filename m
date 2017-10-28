From: David Miller <davem@redhat.com>
Subject: Re: [PATCH V2 net] tuntap: properly align skb->head before
 building skb
Date: Sat, 28 Oct 2017 19:06:15 +0900 (KST)
Message-ID: <20171028.190615.1780763141354795593.davem@redhat.com>
References: <1509073544-4474-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dotweiba@gmail.com, edumazet@google.com,
        willemdebruijn.kernel@gmail.com, dvyukov@google.com,
        mark.rutland@arm.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509073544-4474-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 27 Oct 2017 11:05:44 +0800

> An unaligned alloc_frag->offset caused by previous allocation will
> result an unaligned skb->head. This will lead unaligned
> skb_shared_info and then unaligned dataref which requires to be
> aligned for accessing on some architecture. Fix this by aligning
> alloc_frag->offset before the frag refilling.
> 
> Fixes: 0bbd7dad34f8 ("tun: make tun_build_skb() thread safe")
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
> Cc: Wei Wei <dotweiba@gmail.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Reported-by: Wei Wei <dotweiba@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
