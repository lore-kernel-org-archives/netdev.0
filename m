From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: fore200e.c: fix uninitialized variable
Date: Mon, 14 Jan 2013 18:30:09 -0500 (EST)
Message-ID: <20130114.183009.826634301471863252.davem@davemloft.net>
References: <1358189864-28735-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dinggnu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358189864-28735-1-git-send-email-dinggnu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Ding <dinggnu@gmail.com>
Date: Mon, 14 Jan 2013 18:57:43 +0000

> the variable err is uninitialized if all the macros in the function are
> disabled.

Which is never possible because of the Kconfig dependencies.

This is what happens when you focus to narrowly on a piece of
code, you take no context whatsoever into consideration.
