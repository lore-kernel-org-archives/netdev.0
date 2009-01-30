From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
 up
Date: Thu, 29 Jan 2009 17:09:20 -0800 (PST)
Message-ID: <20090129.170920.43131414.davem@davemloft.net>
References: <20090127120129.GA9696@x200.localdomain>
	<20090127132718.GA10001@x200.localdomain>
	<20090129.170043.180340152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59886
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753279AbZA3BJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 20:09:22 -0500
In-Reply-To: <20090129.170043.180340152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 29 Jan 2009 17:00:43 -0800 (PST)

> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Tue, 27 Jan 2009 16:27:18 +0300
> 
> > [PATCH] sky2: fix hard hang with netconsoling and iface going up
> > 
> > Printing anything over netconsole before hw is up and running is,
> > of course, not going to work.
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> 
> Alexey, can you get this tested by the reporter to make sure
> it really fixes the hang?
> 
> Once it's been tested, I'll apply it.

Actually, I just read the followup where you indicated that
other debugging printk's in this driver might also have the
same problem.

I'm dropping this until everything is resolved, thanks.
