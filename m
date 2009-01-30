From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
 up
Date: Fri, 30 Jan 2009 14:01:04 -0800
Message-ID: <20090130140104.2d0fa89a@extreme>
References: <20090127132718.GA10001@x200.localdomain>
	<20090129.170043.180340152.davem@davemloft.net>
	<20090130115907.GA22534@x200.localdomain>
	<20090130.134550.81676804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44381 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736AbZA3WBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 17:01:07 -0500
In-Reply-To: <20090130.134550.81676804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Jan 2009 13:45:50 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Fri, 30 Jan 2009 14:59:07 +0300
> 
> > On Thu, Jan 29, 2009 at 05:00:43PM -0800, David Miller wrote:
> > > From: Alexey Dobriyan <adobriyan@gmail.com>
> > > Date: Tue, 27 Jan 2009 16:27:18 +0300
> > > 
> > > > [PATCH] sky2: fix hard hang with netconsoling and iface going up
> > > > 
> > > > Printing anything over netconsole before hw is up and running is,
> > > > of course, not going to work.
> > > > 
> > > > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > > 
> > > Alexey, can you get this tested by the reporter to make sure
> > > it really fixes the hang?
> > 
> > I'm the reporter and tester and using this patch successfully. :-)
> 
> Then you give me no choice, I have to apply this patch :-)
> 
> Thanks!

Yes, this is a nice harmless change
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
