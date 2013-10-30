From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Wed, 30 Oct 2013 02:40:03 -0400 (EDT)
Message-ID: <20131030.024003.1476890051483056287.davem@davemloft.net>
References: <1383084998-22673-1-git-send-email-tdmackey@booleanhaiku.com>
	<20131029.224227.1700872646112764527.davem@davemloft.net>
	<CAM_iQpXzJOxZ3MFNthKw5ye=WcxDWbiPaHuL=pHMz7D1R4nJ+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tdmackey@booleanhaiku.com, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXzJOxZ3MFNthKw5ye=WcxDWbiPaHuL=pHMz7D1R4nJ+w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 29 Oct 2013 20:50:08 -0700

> Normally ->poll() is called in softirq context, while netpoll could
> be called in any context depending on its caller.

It still makes amends to make the execution context still looks
"compatible" as far as locking et al. is concerned.
