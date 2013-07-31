From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2/5] net/usb/r815x: avoid to call mdio functions for
 runtime-suspended device
Date: Wed, 31 Jul 2013 14:49:51 -0700 (PDT)
Message-ID: <20130731.144951.812145423086412978.davem@davemloft.net>
References: <D7C722C73C7A400780358D0376412267@realtek.com.tw>
	<1375262486-5373-1-git-send-email-hayeswang@realtek.com>
	<1375262486-5373-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375262486-5373-2-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 31 Jul 2013 17:21:23 +0800

> Don't replace the usb_control_msg() with usbnet_{read,write}_cmd()
> which couldn't be called inside suspend/resume callback. Keep the
> basic functions unlimited. Instead, using usb_autopm_get_interface()
> and usb_autopm_put_interface() in r815x_mdio_{read,write}().
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
