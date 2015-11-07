From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] DWC Ethernet QoS: Delete an unnecessary check before
 the function call "of_node_put"
Date: Fri, 06 Nov 2015 23:33:11 -0500 (EST)
Message-ID: <20151106.233311.2260896695923603885.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<563C5392.6030309@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbbKGEdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 23:33:13 -0500
In-Reply-To: <563C5392.6030309@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 6 Nov 2015 08:15:30 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Fri, 6 Nov 2015 08:00:22 +0100
> 
> The of_node_put() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Please resubmit this with a more appropriate Subject line.

The subsystem prefix should be all lower-case and typically
indicate the most specific subsystem or area being changed.

In this case it's a driver, therefore simply use the driver
name "dwc_eth_qos: ".
