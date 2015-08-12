From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] hv_netvsc: Implement set_channels ethtool
 op
Date: Wed, 12 Aug 2015 14:45:56 -0700 (PDT)
Message-ID: <20150812.144556.430563471959505989.davem@davemloft.net>
References: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
	<1439338472-21361-2-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andschwa@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439338472-21361-2-git-send-email-andschwa@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Date: Tue, 11 Aug 2015 17:14:32 -0700

> This enables the use of ethtool --set-channels devname combined N to
> change the number of vRSS queues. Separate rx, tx, and other parameters
> are not supported. The maximum is rsscap.num_recv_que. It passes the
> given value to rndis_filter_device_add through the device_info->num_chn
> field.
> 
> If the procedure fails, it attempts to recover to the prior state. If
> the recovery fails, it logs an error and aborts.
> 
> Current num_chn is saved and restored when changing the MTU.
> 
> Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>

Applied.
