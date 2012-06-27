From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 7/7] netlink: Get rid of obsolete rtnetlink macros
Date: Wed, 27 Jun 2012 15:31:45 -0700
Message-ID: <20120627153145.1379a30b@nehalam.linuxnetplumber.net>
References: <cover.1340788373.git.tgraf@suug.ch>
	<a10752bf3eb27e13e61b817664d58a69f9179fc9.1340788373.git.tgraf@suug.ch>
	<20120627083532.38566c87@nehalam.linuxnetplumber.net>
	<20120627.150435.67648216442174370.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40030 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065Ab2F0Wbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 18:31:55 -0400
In-Reply-To: <20120627.150435.67648216442174370.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Jun 2012 15:04:35 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 27 Jun 2012 08:35:32 -0700
> 
> > On Wed, 27 Jun 2012 11:36:16 +0200
> > Thomas Graf <tgraf@suug.ch> wrote:
> > 
> >> Removes all RTA_GET*() and RTA_PUT*() variations, as well as the
> >> the unused rtattr_strcmp(). Get rid of rtm_get_table() by moving
> >> it to its only user decnet.
> >> 
> >> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> >> ---
> > 
> > Nack. The RTA_ macros are exported to user space through kernel
> > headers process. If you do this it will break iproute2 build.
> > 
> 
> They are protected by __KERNEL__, what are you talking about?

Never mind, there are copies in other places in iproute

I plan to get rid of the macro versions of this stuff.
It is a nuisance in iproute for the same reason as the kernel.
