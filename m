From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH] net: pxa168_eth: move SET_NETDEV_DEV a bit earlier
Date: Thu, 13 Nov 2014 09:04:52 +0800
Message-ID: <20141113090452.635b4fa0@xhacker>
References: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
	<20141112.150810.806933062338696000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "antoine.tenart@free-electrons.com"
	<antoine.tenart@free-electrons.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141112.150810.806933062338696000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David,

On Wed, 12 Nov 2014 12:08:10 -0800
David Miller <davem@davemloft.net> wrote:

> From: Jisheng Zhang <jszhang@marvell.com>
> Date: Wed, 12 Nov 2014 19:08:47 +0800
> 
> > This is to ensure the net_device's dev.parent is set before we used it
> > in dma_zalloc_coherent() from init_hash_table().
> > 
> > Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> 
> Please always be explicit about what tree you generated this patch against
> and therefore expect it to be applied to by saying "[PATCH net-next]" or
> similar in your Subject line.

Got it. I will take care next time.

Thanks a lot
