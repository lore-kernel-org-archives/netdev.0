From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 53/73] drivers/isdn: delete non-required instances of
 include <linux/init.h>
Date: Tue, 21 Jan 2014 14:35:39 -0800 (PST)
Message-ID: <20140121.143539.1671260005279546451.davem@davemloft.net>
References: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
	<1390339396-3479-54-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	isdn@linux-pingi.de, mac@melware.de, netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390339396-3479-54-git-send-email-paul.gortmaker@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 21 Jan 2014 16:22:56 -0500

> None of these files are actually using any __init type directives
> and hence don't need to include <linux/init.h>.  Most are just a
> left over from __devinit and __cpuinit removal, or simply due to
> code getting copied from one driver to the next.
> 
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: Armin Schindler <mac@melware.de> (maintainer:ISDN SUBSYSTEM
> Cc: netdev@vger.kernel.org
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: David S. Miller <davem@davemloft.net>
