From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dwc_eth_qos: Delete an unnecessary check before the
 function call "of_node_put"
Date: Sat, 07 Nov 2015 13:19:38 -0500 (EST)
Message-ID: <20151107.131938.1320322327069111312.davem@davemloft.net>
References: <563C5392.6030309@users.sourceforge.net>
	<20151106.233311.2260896695923603885.davem@davemloft.net>
	<563E1A18.101@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <563E1A18.101@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 7 Nov 2015 16:34:48 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 7 Nov 2015 16:30:34 +0100
> 
> The of_node_put() function tests whether its argument is NULL
> and then returns immediately.
> Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
