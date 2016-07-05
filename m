From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] connector: make cn_proc explicitly non-modular
Date: Tue, 05 Jul 2016 11:41:23 -0700 (PDT)
Message-ID: <20160705.114123.113903664958645436.davem@davemloft.net>
References: <20160704215058.13593-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, zbr@ioremap.net,
	netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160704215058.13593-1-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 4 Jul 2016 17:50:58 -0400

> The Kconfig controlling build of this code is currently:
> 
> drivers/connector/Kconfig:config PROC_EVENTS
> drivers/connector/Kconfig:      bool "Report process events to userspace"
> 
> ...meaning that it currently is not being built as a module by anyone.
> Lets remove the two modular references, so that when reading the driver
> there is no doubt it is builtin-only.
> 
> Since module_init translates to device_initcall in the non-modular
> case, the init ordering remains unchanged with this commit.
> 
> Cc: Evgeniy Polyakov <zbr@ioremap.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
