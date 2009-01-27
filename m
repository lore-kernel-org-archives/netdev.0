From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: fix hard hang with netconsoling and iface going
 up
Date: Tue, 27 Jan 2009 09:49:28 -0800
Message-ID: <20090127094928.534ff6f6@extreme>
References: <20090127120129.GA9696@x200.localdomain>
	<20090127132718.GA10001@x200.localdomain>
	<20090127133504.GA10091@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48644 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755853AbZA0Rt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:49:56 -0500
In-Reply-To: <20090127133504.GA10091@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Jan 2009 16:35:04 +0300
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Tue, Jan 27, 2009 at 04:27:18PM +0300, Alexey Dobriyan wrote:
> > On Tue, Jan 27, 2009 at 03:01:29PM +0300, Alexey Dobriyan wrote:
> > > If sky2 interface is netconsoling, then
> > > 
> > > 	ifconfig down; ifconfig up
> > > 
> > > leads to hard hang after printing
> > > 
> > > 	sky2 eth0: enabling interface
> > > 
> > > SysRq+b reboots the box, nothing else works (or prints something).
> > > 
> > > This is with 2.6.28.2 and 2.6.29-rc2-5ee810072175042775e39bdd3eaaa68884c27805.
> > > Most certainly was there since day one.
> > > 
> > > Haven't investigated further.
> > 
> > Well, duh...
> > 
> > 
> > [PATCH] sky2: fix hard hang with netconsoling and iface going up
> > 
> > Printing anything over netconsole before hw is up and running is,
> > of course, not going to work.
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
>

Netconsole should be smart enough to not try and print to
a device that is not marked running.
