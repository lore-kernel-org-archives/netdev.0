From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fjes: Delete an unnecessary check before the function
 call "vfree"
Date: Sat, 07 Nov 2015 13:18:43 -0500 (EST)
Message-ID: <20151107.131843.218377814617040539.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563C673B.1020605@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <563C673B.1020605@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 6 Nov 2015 09:39:23 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 6 Nov 2015 09:30:29 +0100
> 
> The vfree() function performs also input parameter validation.
> Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
