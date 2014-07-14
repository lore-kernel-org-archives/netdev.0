From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: mark napi id for gro_skb
Date: Mon, 14 Jul 2014 16:14:35 -0700 (PDT)
Message-ID: <20140714.161435.909932787419949578.davem@davemloft.net>
References: <1405309364-32258-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405309364-32258-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 14 Jul 2014 11:42:44 +0800

> Napi id was not marked for gro_skb, this will lead rx busy loop won't
> work correctly since they stack never try to call low latency receive
> method because of a zero socket napi id. Fix this by marking napi id
> for gro_skb.
> 
> The transaction rate of 1 byte netperf tcp_rr gets about 50% increased
> (from 20531.68 to 30610.88).
> 
> Cc: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
