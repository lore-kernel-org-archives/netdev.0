From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] Fix dm9000 release_resource
Date: Thu, 31 Aug 2006 09:32:12 +0200
Message-ID: <20060831073212.GB13103@localhost.localdomain>
References: <0ML25U-1GIK8C13Mq-0007lB@mrelayeu.kundenserver.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Dooks <ben@simtec.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:24763 "EHLO
	metis.extern.pengutronix.de") by vger.kernel.org with ESMTP
	id S1751137AbWHaHcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 03:32:25 -0400
To: Dirk Opfer <Dirk@Opfer-Online.de>
Content-Disposition: inline
In-Reply-To: <0ML25U-1GIK8C13Mq-0007lB@mrelayeu.kundenserver.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2006 at 09:04:45AM +0200, Dirk Opfer wrote:
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

I thought this was fixed long ago, it must have been lost somewhere.
Anyway:

Acked-by: Sascha Hauer <s.hauer@pengutronix.de>



-- 
 Dipl.-Ing. Sascha Hauer | http://www.pengutronix.de
  Pengutronix - Linux Solutions for Science and Industry
    Handelsregister: Amtsgericht Hildesheim, HRA 2686
      Hannoversche Str. 2, 31134 Hildesheim, Germany
    Phone: +49-5121-206917-0 |  Fax: +49-5121-206917-9
