From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: use symmetric hash
Date: Tue, 06 Jun 2017 16:24:51 -0400 (EDT)
Message-ID: <20170606.162451.1599168649615704999.davem@davemloft.net>
References: <1496729389-15221-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496729389-15221-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Tue,  6 Jun 2017 14:09:49 +0800

> Tun actually expects a symmetric hash for queue selecting to work
> correctly, otherwise packets belongs to a single flow may be
> redirected to the wrong queue. So this patch switch to use
> __skb_get_hash_symmetric().
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
