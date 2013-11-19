From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: idt77252: fix dev refcnt leak
Date: Tue, 19 Nov 2013 15:53:35 -0500 (EST)
Message-ID: <20131119.155335.1285719229777563134.davem@davemloft.net>
References: <1384855767-21446-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384855767-21446-1-git-send-email-ying.xue@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 19 Nov 2013 18:09:27 +0800

> init_card() calls dev_get_by_name() to get a network deceive. But it
> doesn't decrease network device reference count after the device is
> used.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Applied and queued up for -stable, thanks.
