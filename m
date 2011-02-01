From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxge: Fix wrong boolean operator
Date: Mon, 31 Jan 2011 20:55:53 -0800 (PST)
Message-ID: <20110131.205553.39195952.davem@davemloft.net>
References: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.mason@exar.com, ramkrishna.vepa@exar.com,
	sivakumar.subramani@exar.com, sreenivasa.honnur@exar.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: weil@mail.berlios.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296253817-7668-1-git-send-email-weil@mail.berlios.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Weil <weil@mail.berlios.de>
Date: Fri, 28 Jan 2011 23:30:17 +0100

> This error is reported by cppcheck:
> drivers/net/vxge/vxge-config.c:3693: warning: Mutual exclusion over || always evaluates to true. Did you intend to use && instead?
> 
> It looks like cppcheck is correct, so fix this. No test was run.
> 
> Cc: Ramkrishna Vepa <ramkrishna.vepa@exar.com>
> Cc: Sivakumar Subramani <sivakumar.subramani@exar.com>
> Cc: Sreenivasa Honnur <sreenivasa.honnur@exar.com>
> Cc: Jon Mason <jon.mason@exar.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>

Can the VXGE folks please review this patch?
