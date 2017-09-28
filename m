From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tun: bail out from tun_get_user() if the skb is
 empty
Date: Thu, 28 Sep 2017 08:42:52 -0700 (PDT)
Message-ID: <20170928.084252.253155943275207205.davem@davemloft.net>
References: <20170928093237.121450-1-glider@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dvyukov@google.com,
        syzkaller@googlegroups.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: glider@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928093237.121450-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Potapenko <glider@google.com>
Date: Thu, 28 Sep 2017 11:32:37 +0200

> KMSAN (https://github.com/google/kmsan) reported accessing uninitialized
> skb->data[0] in the case the skb is empty (i.e. skb->len is 0):
 ...
> Make sure tun_get_user() doesn't touch skb->data[0] unless there is
> actual data.
 ...
> Signed-off-by: Alexander Potapenko <glider@google.com>

Applied and queued up for -stable, thanks.
