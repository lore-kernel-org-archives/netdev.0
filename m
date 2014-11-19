From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: pktgen: Deletion of an unnecessary check
 before the function call "proc_remove"
Date: Wed, 19 Nov 2014 15:20:26 -0500 (EST)
Message-ID: <20141119.152026.2218359090239941545.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<546B9AF5.9050809@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, cocci@systeme.lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546B9AF5.9050809@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 18 Nov 2014 20:16:05 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 18 Nov 2014 20:10:34 +0100
> 
> The proc_remove() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied, thanks.
