From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] r8152: add supporting the vendor mode only
Date: Mon, 13 Jan 2014 11:19:36 -0800 (PST)
Message-ID: <20140113.111936.1286616042680494607.davem@davemloft.net>
References: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
	<1389250232-8663-4-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389250232-8663-4-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 9 Jan 2014 14:50:32 +0800

> Remove the limitation that the ecm and r8152 drivers couldn't coexist.
> Besides, add the feature to support the vendor mode only. This let
> someone who doesn't want to use ecm driver easy to use the vendor
> driver without creating the udev rule.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

This is a very bad precedence and I do not want drivers to start doing
things like this.

I think it would be wiser to use the existing facilities which exist
to control this situation, and yes udev is one of them.

I'm sorry, I'm not applying this series as long as it has this patch
in it.
