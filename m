From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: Delete an unnecessary check before the function
 call "irlmp_unregister_service"
Date: Tue, 03 Nov 2015 13:31:07 -0500 (EST)
Message-ID: <20151103.133107.8373482880165720.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<5638EF52.7030300@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5638EF52.7030300@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 3 Nov 2015 18:30:58 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 3 Nov 2015 18:18:37 +0100
> 
> The irlmp_unregister_service() function tests whether its argument is NULL
> and then returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
