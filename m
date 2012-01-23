From: Viral Mehta <viral.vkm@gmail.com>
Subject: Re: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 14:10:44 +0530
Message-ID: <CANX6Da=Y5zJ4xi8=gLZZ8tUnnqxNCpvC0yBGruObWzYHrucLLg@mail.gmail.com>
References: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2012 at 2:27 AM, Pradeep A. Dalvi
<netdev@pradeepdalvi.com> wrote:
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>
> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>

and these too ??

vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$ grep dev_alloc_skb -r .
./ipath/ipath_driver.c:	skb = __dev_alloc_skb(len, gfp_mask);
./nes/nes_cm.c:	skb = dev_alloc_skb(MAX_CM_BUFFER);
./nes/nes_cm.c:		skb = dev_alloc_skb(MAX_CM_BUFFER);
./nes/nes_cm.c:		skb = dev_alloc_skb(MAX_CM_BUFFER);
./nes/nes_cm.c:		skb = dev_alloc_skb(MAX_CM_BUFFER);
./nes/nes_cm.c:		skb = dev_alloc_skb(MAX_CM_BUFFER);
./nes/nes_hw.c:		skb = dev_alloc_skb(nesvnic->max_frame_size);
./nes/nes_hw.c:		skb = dev_alloc_skb(nesvnic->max_frame_size);
./nes/nes_mgt.c:		skb = dev_alloc_skb(mgtvnic->nesvnic->max_frame_size);
./nes/nes_mgt.c:			skb = dev_alloc_skb(nesvnic->max_frame_size);
./amso1100/c2.c:	skb = dev_alloc_skb(c2_port->rx_buf_size);
vmehta@viralmehta:~/linux-3.2/drivers/infiniband/hw$
