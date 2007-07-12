From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: RFC: removing DONGLE_OLD drivers?
Date: Fri, 13 Jul 2007 01:30:19 +0300
Message-ID: <20070712223018.GA3576@sortiz.org>
References: <20070709172539.GF3492@stusta.de>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.94]:46664 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757653AbXGLXDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 19:03:06 -0400
Received: from smtp27.orange.fr (mwinf2704 [10.232.12.26])
	by mwinf2705.orange.fr (SMTP Server) with ESMTP id B87C71C19E31
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 00:58:22 +0200 (CEST)
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2704.orange.fr (SMTP Server) with ESMTP id 9CBC81C04CF3
	for <netdev@vger.kernel.org>; Fri, 13 Jul 2007 00:42:00 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20070709172539.GF3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Adrian,

On Mon, Jul 09, 2007 at 07:25:39PM +0200, Adrian Bunk wrote:
> With one exception, all DONGLE_OLD drivers have newer counterparts.
> 
> The DONGLE_OLD drivers depend on BROKEN_ON_SMP which e.g. implies that 
> the many distributions shipping only SMP-kernels will never offer them.
> 
> The one exception is a driver for the Cirrus Logic EDB-7211 evaluation 
> board that itself is out of production for some years.
> 
> Can we remove these old drivers or is there a good reason for keeping 
> them?
I didn't notice the ep7211 is only using the old dongle API.
I'll convert it to the new one, and then we can start looking at getting
rid of the old drivers.

Cheers,
Samuel.



> cu
> Adrian
> 
> -- 
> 
>        "Is there not promise of rain?" Ling Tan asked suddenly out
>         of the darkness. There had been need of rain for many days.
>        "Only a promise," Lao Er said.
>                                        Pearl S. Buck - Dragon Seed
> 

