From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] atm: idt77252: Remove redundant error check
Date: Sun, 18 May 2014 21:14:12 -0400 (EDT)
Message-ID: <20140518.211412.1525385415713413915.davem@davemloft.net>
References: <1400350980-30455-3-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400350980-30455-3-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Sat, 17 May 2014 20:22:59 +0200

> Remove double checks, and move the call to printk to the
> first check. Also adds KERN_WARNING to printk. The simplified version
> of the coccinelle semantic patch that fixes this issue is as follows:

The appropriate thing to use is pr_warning() rather than add
KERN_WARNING.
