From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IBM-EMAC: Delete an unnecessary check before the
 function call "of_dev_put"
Date: Wed, 04 Feb 2015 20:29:58 -0800 (PST)
Message-ID: <20150204.202958.1260717828060513191.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<54D118BA.3080001@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D118BA.3080001@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 03 Feb 2015 19:51:38 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Tue, 3 Feb 2015 19:47:33 +0100
> 
> The of_dev_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
