From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: make tun_build_skb() thread safe
Date: Wed, 16 Aug 2017 22:29:55 +0800
Message-ID: <10bb7c67-d30f-2f72-9e16-a9c3a99bc7fc@redhat.com>
References: <1502892873-10770-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502892873-10770-1-git-send-email-jasowang@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年08月16日 22:14, Jason Wang wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
>
> tun_build_skb() is not thread safe since it uses per queue page frag,
> this will break things when multiple threads are sending through same
> queue. Switch to use per-thread generator (no lock involved).
>
> Fixes: 66ccbc9c87c2 ("tap: use build_skb() for small packet")
> Tested-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>   drivers/net/tun.c | 7 +------

Forget to mention, this is for net-next.

Thanks
