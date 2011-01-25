From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] USB NET KL5KUSB101: Fix mem leak in error path of
 kaweth_download_firmware()
Date: Mon, 24 Jan 2011 23:20:35 -0800 (PST)
Message-ID: <20110124.232035.183057878.davem@davemloft.net>
References: <alpine.LNX.2.00.1101232315230.30955@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gregkh@suse.de, zapman@interlan.net,
	rothwell@interlan.net
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1101232315230.30955@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 23 Jan 2011 23:19:55 +0100 (CET)

> We will leak the storage allocated by request_firmware() if the size of 
> the firmware is greater than KAWETH_FIRMWARE_BUF_SIZE.
> This removes the leak by calling release_firmware() before we return 
> -ENOSPC.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

Applied, thanks Jesper.
