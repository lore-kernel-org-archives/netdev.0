From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 6/8] drivers/char/hw_random.c: remove assert()'s
Date: Fri, 09 Jun 2006 10:19:35 -0400
Message-ID: <44898377.2090602@garzik.org>
References: <200606090519.k595JlHj032029@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:62088 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965273AbWFIOTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 10:19:45 -0400
To: akpm@osdl.org
In-Reply-To: <200606090519.k595JlHj032029@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Adrian Bunk <bunk@stusta.de>
> 
> Remove the assert()'s from drivers/char/hw_random.c since you both needed
> to enable a manual option in the driver source to make them effective and
> they only covered some obviously impossible cases.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

100% NAK.  They are there, obviously, for driver debugging and 
development.  Just like libata's debug stuff, you certainly have to 
enable them manually.

Until this driver goes away (real soon, right?), the debugging facility 
should stay.

	Jeff



