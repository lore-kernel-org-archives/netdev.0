From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Re [RFC PATCH 1/2] iproute2: Add libnl support.
Date: Tue, 30 Mar 2010 14:40:12 -0700
Message-ID: <20100330144012.6ad28c1f@nehalam>
References: <20100329140642.7305bdfc@nehalam>
	<4BB1ACDA.8030808@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45594 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754049Ab0C3Vk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:40:29 -0400
In-Reply-To: <4BB1ACDA.8030808@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 08:48:42 +0100
James Chapman <jchapman@katalix.com> wrote:

> Stephen Hemminger wrote:
> >> This patch links the ip utility with libnl, which must be separately
> >> installed. This lets new functionality use libnl to implement its
> >> netlink interfaces.
> >>
> >> Package developers will need to add libnl to the iproute2 package
> >> dependencies.
> >> ---
> >>  Makefile |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > No. I don't want to make iproute2 dependent on libnl.
> > It doesn't make sense to have dependency without major need for new
> > functionality.  There are already netlink library routines in iproute2
> 
> True, but libnetlink doesn't provide utility routines for building genl
> interfaces like it does, say, for rtnl. To use libnetlink for this code,
> we'd have to c&p some code from genl/ctrl.c to handle the interface
> family registration, for example. It's all there in libnl already.
> 
> But I understand your reservation about introducing a new library
> dependency. Since the rest of our netlink code uses libnl, I'm leaning
> towards having a separate utility for these commands so we can keep it
> libnl.
> 

Please use extend genl/ctrl.c to handle your lt2pv3 messages.
