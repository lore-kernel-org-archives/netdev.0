From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH] [PPPOL2TP] Label unused warning when CONFIG_PROC_FS is
 not set.
Date: Tue, 05 Feb 2008 17:38:10 +0000
Message-ID: <47A89F02.8010403@katalix.com>
References: <eb3ff54b0802050415h3c4672b1r7048143b599303dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:58262 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbYBERiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 12:38:15 -0500
In-Reply-To: <eb3ff54b0802050415h3c4672b1r7048143b599303dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: James Chapman <jchapman@katalix.com>

Rami Rosen wrote:
> Hi,
> 
> When CONFIG_PROC_FS is not set and CONFIG_PPPOL2TP is set,
> we have the following warning in build:
>   drivers/net/pppol2tp.c: In function 'pppol2tp_init':
>   drivers/net/pppol2tp.c:2472: warning: label
> 'out_unregister_pppox_proto' defined but not used
> 
> This patches fixes this warning by adding appropriate #ifdef.
> 
> Regards,
> Rami Rosen
> 
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>
> 


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

