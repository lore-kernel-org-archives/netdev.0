From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix dm9000 release_resource
Date: Wed, 06 Sep 2006 10:58:44 -0400
Message-ID: <44FEE224.7030904@garzik.org>
References: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>,
	Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40665 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751255AbWIFO6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 10:58:50 -0400
To: Dirk@Opfer-Online.de
In-Reply-To: <0ML25U-1GIK892FsT-0007pS@mrelayeu.kundenserver.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dirk Opfer wrote:
> dm9000_release_board calls release_resource with the platform resource
> instead of the requested resource:
> 
> db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> db->addr_req = request_mem_region(db->addr_res->start, i, pdev->name);
> 
> dm9000_release_board:
> 
>     if (db->addr_res != NULL) {
>         release_resource(db->addr_res);
>         kfree(db->addr_req);
> 
> With this behavior the kernel will crash on the second removal. The
> attached patch fix this problem.
> 
> 
> Signed-off-by: Dirk Opfer <Dirk@Opfer-Online.de>

Your patch is attached base64-encoded, which makes it impossible to 
comment on it inline.

	Jeff


