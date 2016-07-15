From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] macvtap: avoid hash calculating for
 single queue
Date: Fri, 15 Jul 2016 14:40:54 -0700 (PDT)
Message-ID: <20160715.144054.1758876801096882335.davem@davemloft.net>
References: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 15 Jul 2016 03:46:30 -0400

> We decide the rxq through calculating its hash which is not necessary
> if we only have one rx queue. So this patch skip this and just return
> queue 0. Test shows 22% improving on guest rx pps.
> 
> Before: 1201504 pkts/s
> After:  1472731 pkts/s
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
