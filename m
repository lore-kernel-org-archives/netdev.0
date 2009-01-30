From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
	up
Date: Fri, 30 Jan 2009 14:59:07 +0300
Message-ID: <20090130115907.GA22534@x200.localdomain>
References: <20090127120129.GA9696@x200.localdomain> <20090127132718.GA10001@x200.localdomain> <20090129.170043.180340152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:42808 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805AbZA3LxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 06:53:23 -0500
Received: by ewy14 with SMTP id 14so706842ewy.13
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2009 03:53:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090129.170043.180340152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2009 at 05:00:43PM -0800, David Miller wrote:
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

I'm the reporter and tester and using this patch successfully. :-)

> Once it's been tested, I'll apply it.

As for other printks, someone with 8139cp should experience the same bug.
