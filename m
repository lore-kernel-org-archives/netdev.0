From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net-ipvlan: Deletion of an unnecessary check
 before the function call "free_percpu"
Date: Fri, 05 Dec 2014 21:14:58 -0800 (PST)
Message-ID: <20141205.211458.852732910784554172.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<5479E693.3010200@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbaLFFK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 00:10:28 -0500
In-Reply-To: <5479E693.3010200@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 29 Nov 2014 16:30:27 +0100

> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Sat, 29 Nov 2014 16:23:20 +0100
> 
> The free_percpu() function tests whether its argument is NULL and then
> returns immediately. Thus the test around the call is not needed.
> 
> This issue was detected by using the Coccinelle software.
> 
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Applied.
