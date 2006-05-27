From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] via-velocity: allow MTU size less than 1500 bytes
Date: Fri, 26 May 2006 22:20:27 -0400
Message-ID: <4477B76B.70700@pobox.com>
References: <1148393221.2479.29.camel@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41444 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S964890AbWE0CUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 22:20:30 -0400
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <1148393221.2479.29.camel@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> Change the minimum allowable MTU size from 1500 bytes to 64 bytes.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> 
> --- linux-2.6.16.x86_64/drivers/net/via-velocity.h.orig 2006-05-23 07:42:24.000000000 -0500
> +++ linux-2.6.16.x86_64/drivers/net/via-velocity.h      2006-05-23 08:31:17.000000000 -0500
> @@ -307,7 +307,7 @@
>  #define TX_QUEUE_NO         4
> 
>  #define MAX_HW_MIB_COUNTER  32
> -#define VELOCITY_MIN_MTU    (1514-14)
> +#define VELOCITY_MIN_MTU    (64)
>  #define VELOCITY_MAX_MTU    (9000)

ACK, but patch won't apply:


[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
1 patch(es) to process.

Applying 'via-velocity: allow MTU size less than 1500 bytes'

fatal: corrupt patch at line 5
