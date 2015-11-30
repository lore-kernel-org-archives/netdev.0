From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] Minor improvement for smsc95xx netusb driver
 performance.
Date: Sun, 29 Nov 2015 23:00:51 -0500 (EST)
Message-ID: <20151129.230051.1339628952619269873.davem@davemloft.net>
References: <1448488526-8040-1-git-send-email-AmeenAli023@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: ameenali023@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448488526-8040-1-git-send-email-AmeenAli023@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ameen <ameenali023@gmail.com>
Date: Wed, 25 Nov 2015 23:55:26 +0200

>  	if (csum)
> -		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
> -	cpu_to_le32s(&tx_cmd_b);
> -	memcpy(skb->data, &tx_cmd_b, 4);
> +	  tx_cmds.cmd_b |= TX_CMD_B_CSUM_ENABLE;

You've corrupted the indentation here.
