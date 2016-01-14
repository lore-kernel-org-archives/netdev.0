From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl/fman: Delete one function call "put_device" in
 dtsec_config()
Date: Thu, 14 Jan 2016 16:51:21 -0500 (EST)
Message-ID: <20160114.165121.1797769104831484799.davem@davemloft.net>
References: <20160113213537.GD4399@mwanda>
	<20160113220923.GE5527@lunn.ch>
	<5697B81E.4050303@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, dan.carpenter@oracle.com,
	igal.liberman@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5697B81E.4050303@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 14 Jan 2016 16:00:46 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 14 Jan 2016 15:46:28 +0100
> 
> The Coccinelle semantic patch script "deref_null.cocci" pointed a problem
> out in the implementation of the function "dtsec_config".
> 
> A null pointer was assigned to the data structure member "tbiphy" of the
> variable "dtsec" if a matching device was not found.
> A call of the function "put_device" was unnecessary then because
> a previous call of the function "get_device" was not triggered.
> Thus remove the function call "put_device" after the printing of the
> desired error message.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied, thanks.
