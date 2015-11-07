From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet-synopsys: Delete an unnecessary check before
 of_node_put()
Date: Sat, 07 Nov 2015 09:50:13 -0500 (EST)
Message-ID: <20151107.095013.902059569721693135.davem@davemloft.net>
References: <563C5392.6030309@users.sourceforge.net>
	<20151106.233311.2260896695923603885.davem@davemloft.net>
	<563E077C.3090201@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <563E077C.3090201@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 7 Nov 2015 15:15:24 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 7 Nov 2015 15:10:29 +0100
> 
> The of_node_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

As I requested of you last night, please phrase the subsystem
prefix of your Subject lines more correctly.

Just use the driver's name, in lower case, as one single word,
which in this case would be "dwc_eth_qos: ".

I'm telling you exactly what to use in the Subject line, there
is no ambiguity or confusion on what you need to do for me to
accept this patch.

Thanks.
