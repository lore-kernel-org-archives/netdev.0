From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bluetooth : rfcomm tty BUG_ON() code fix
Date: Thu, 10 Jan 2008 22:23:20 -0800 (PST)
Message-ID: <20080110.222320.247508342.davem@davemloft.net>
References: <20080107054122.GA4502@darkstar.te-china.tietoenator.com>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	bluez-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: hidave.darkstar@gmail.com
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080107054122.GA4502@darkstar.te-china.tietoenator.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar@gmail.com>
Date: Mon, 7 Jan 2008 13:41:22 +0800

> 1) In tty.c the BUG_ON at line 115 will never be called, because the the before list_del_init in this same function.
>  115          BUG_ON(!list_empty(&dev->list));
> So move the list_del_init to rfcomm_dev_del 
> 
> 2) The rfcomm_dev_del could be called from diffrent path (rfcomm_tty_hangup/rfcomm_dev_state_change/rfcomm_release_dev),
> So add another BUG_ON when the rfcomm_dev_del is called more than one time.
> 
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com> 

Applied, thanks Dave.

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
