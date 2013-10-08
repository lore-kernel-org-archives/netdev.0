From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: don't look at current when non-blocking
Date: Tue, 08 Oct 2013 15:46:14 -0400 (EDT)
Message-ID: <20131008.154614.1435858706789904414.davem@davemloft.net>
References: <20131006182512.GA16504@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jasowang@redhat.com, edumazet@google.com, xemul@parallels.com
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131006182512.GA16504@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 6 Oct 2013 21:25:12 +0300

> We play with a wait queue even if socket is
> non blocking. This is an obvious waste.
> Besides, it will prevent calling the non blocking
> variant when current is not valid.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied and queued up for -stable, thanks.
