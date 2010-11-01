From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
Date: Mon, 01 Nov 2010 09:34:09 -0700 (PDT)
Message-ID: <20101101.093409.189716653.davem@davemloft.net>
References: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru>
	<AANLkTi=B93UqfiBFMFryLk1wxus6LwHsSo+8+Ff5D0Ne@mail.gmail.com>
	<4CCEEAEA.4050504@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mad_soft@inbox.ru, dbrownell@users.sourceforge.net, gregkh@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: dkirjanov@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CCEEAEA.4050504@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Kirjanov <dkirjanov@kernel.org>
Date: Mon, 01 Nov 2010 19:29:30 +0300

> [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
> 
> Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
> register_netdevice"), which moved tx netqueue creation into register_netdev.
> So now calling netif_stop_queue() before register_netdev causes an oops.
> Move netif_stop_queue() after net device registration to fix crash.
> 
> Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
> Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>

Applied, thanks.
