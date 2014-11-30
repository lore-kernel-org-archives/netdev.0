From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: delay the header check for dodgy
 packets into lower device
Date: Sat, 29 Nov 2014 20:45:03 -0800 (PST)
Message-ID: <20141129.204503.879046243709537472.davem@davemloft.net>
References: <1416993674-11177-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, vyasevic@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416993674-11177-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 26 Nov 2014 17:21:14 +0800

> We do header check twice for a dodgy packet. One is done before
> macvlan_start_xmit(), another is done before lower device's
> ndo_start_xmit(). The first one seems redundant so this patch tries to
> delay header check until a packet reaches its lower device (or macvtap)
> through always enabling NETIF_F_GSO_ROBUST for macvlan device.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
