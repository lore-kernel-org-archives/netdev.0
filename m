From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: make tun_build_skb() thread safe
Date: Wed, 16 Aug 2017 14:27:52 -0700 (PDT)
Message-ID: <20170816.142752.600537690273356198.davem@davemloft.net>
References: <1502892873-10770-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com, eric.dumazet@gmail.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502892873-10770-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 16 Aug 2017 22:14:33 +0800

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

Applied, thanks.
