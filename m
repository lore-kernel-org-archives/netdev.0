From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 10:27:21 -0500
Message-ID: <1150990041.3040.6.camel@stevo-desktop>
References: <20060621184519.10425.69175.stgit@stevo-desktop>
	 <20060622.015728.59653992.davem@davemloft.net>
	 <1150984380.27156.4.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:14397 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S932216AbWFVP1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 11:27:30 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <1150984380.27156.4.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 08:53 -0500, Steve Wise wrote:
> On Thu, 2006-06-22 at 01:57 -0700, David Miller wrote:
> > From: Steve Wise <swise@opengridcomputing.com>
> > Date: Wed, 21 Jun 2006 13:45:19 -0500
> > 
> > > This patch implements a mechanism that allows interested clients to
> > > register for notification of certain network events.
> > 
> > We have a generic network event notification facility called
> > netlink, please use it and extend it for your needs if necessary.
> 
> I'll investigate this.  
> 
> Thanks,


The in-kernel Infiniband subsystem needs to know when certain events
happen.  For example, if the mac address of a neighbour changes.  Any
rdma devices that are using said neighbour need to be notified of the
change.  You are asking that I extend the netlink facility (if
necessary) to provide this functionality.  

Are you suggesting, then, that the Infiniband subsystem should create an
in-kernel NETLINK socket and obtain these events (and the pertinent
information) via the socket?  

I'm still learning about netlink, but my understanding to date is that
its a way to pass events/commands between the kernel and user
applications.  It perhaps seems overkill to use this mechanism for
kernel->kernel event notifications.  That's why I started with notifier
blocks and added a netevent_notifier mechanism.

Any help is greatly appreciated.  Sorry if I'm being dense...

Steve.

