From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ATHEROS-ATL1E: Convert iounmap to pci_iounmap
Date: Tue, 18 Mar 2014 16:13:20 -0400 (EDT)
Message-ID: <20140318.161320.2140829838583694961.davem@davemloft.net>
References: <1395159085-11691-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com,
	hannes@stressinduktion.org, nhorman@tuxdriver.com, kaber@trash.net,
	sd@queasysnail.net, PeterHuewe@gmx.de, andrea.merello@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: peter.senna@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395159085-11691-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>
Date: Tue, 18 Mar 2014 17:11:24 +0100

> Use pci_iounmap instead of iounmap when the virtual mapping was done
> with pci_iomap. A simplified version of the semantic patch that finds this
> issue is as follows: (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied, thanks.
