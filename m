From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-Liquidio: Delete unnecessary checks before the
 function call "vfree"
Date: Mon, 29 Jun 2015 09:28:23 -0700 (PDT)
Message-ID: <20150629.092823.165902372857729782.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<55912270.4030201@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, rric@kernel.org,
	satananda.burla@caviumnetworks.com, sgoutham@cavium.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55912270.4030201@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 29 Jun 2015 12:48:16 +0200

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 29 Jun 2015 12:22:24 +0200
> 
> The vfree() function performs also input parameter validation.
> Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
