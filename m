From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: fix the submission of the interrupt transfer
Date: Thu, 06 Feb 2014 20:39:50 -0800 (PST)
Message-ID: <20140206.203950.905861192240833461.davem@davemloft.net>
References: <1391658948-4456-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391658948-4456-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 6 Feb 2014 11:55:48 +0800

> The submission of the interrupt transfer should be done after setting
> the bit of WORK_ENABLE, otherwise the callback function would have
> the opportunity to be returned directly.
> 
> Clear the bit of WORK_ENABLE before killing the interrupt transfer.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
