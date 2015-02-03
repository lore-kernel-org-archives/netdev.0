From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: Deletion of an unnecessary check before the
 function call "kfree"
Date: Mon, 02 Feb 2015 19:30:12 -0800 (PST)
Message-ID: <20150202.193012.1930991920361082218.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54CD0DCF.9020804@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CD0DCF.9020804@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 31 Jan 2015 18:15:59 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 31 Jan 2015 18:10:03 +0100
> 
> The kfree() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied to net-next, thanks.
