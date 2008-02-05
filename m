From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [PPPOL2TP] Label unused warning when CONFIG_PROC_FS is
 not set.
Date: Tue, 05 Feb 2008 13:22:19 -0500
Message-ID: <47A8A95B.4060905@garzik.org>
References: <eb3ff54b0802050415h3c4672b1r7048143b599303dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41932 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbYBESWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:22:22 -0500
In-Reply-To: <eb3ff54b0802050415h3c4672b1r7048143b599303dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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


David or Paul, wanna pick this up?

