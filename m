From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/3] net/usb/r8152: support aggregation
Date: Thu, 15 Aug 2013 01:34:51 -0700 (PDT)
Message-ID: <20130815.013451.1035905405652002272.davem@davemloft.net>
References: <1376378913-879-1-git-send-email-hayeswang@realtek.com>
	<1376484880-741-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376484880-741-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 14 Aug 2013 20:54:38 +0800

> Enable the tx/rx aggregation which could contain one or more packets
> for each bulk in/out. This could reduce the loading of the host
> controller by sending less bulk transfer.
> 
> The rx packets in the bulk in buffer should be 8-byte aligned, and
> the tx packets in the bulk out buffer should be 4-byte aligned.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
