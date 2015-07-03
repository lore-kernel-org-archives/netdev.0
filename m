From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-RDS: Delete an unnecessary check before the
 function call "module_put"
Date: Fri, 03 Jul 2015 09:28:13 -0700 (PDT)
Message-ID: <20150703.092813.145273282420775033.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<559561F3.2040107@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <559561F3.2040107@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 02 Jul 2015 18:08:19 +0200

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Thu, 2 Jul 2015 17:58:21 +0200
> 
> The module_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
