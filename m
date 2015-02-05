From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlogic: Deletion of unnecessary checks before two
 function calls
Date: Thu, 05 Feb 2015 00:33:31 -0800 (PST)
Message-ID: <20150205.003331.1969979020399013915.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54D21B01.30802@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D21B01.30802@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 04 Feb 2015 14:13:37 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Wed, 4 Feb 2015 14:07:56 +0100
> 
> The functions kfree() and vfree() perform also input parameter validation.
> Thus the test around their calls is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
