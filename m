From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPROUTE 00/02]: rtnl_link support
Date: Wed, 13 Jun 2007 10:48:54 -0700
Message-ID: <20070613104854.4f582711@localhost>
References: <20070613170229.8318.75488.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49438 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758226AbXFMRtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:49:45 -0400
In-Reply-To: <20070613170229.8318.75488.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Jun 2007 19:02:32 +0200 (MEST)
Patrick McHardy <kaber@trash.net> wrote:

> Hi Stephen,
> 
> these patches add support for the rtnl_link stuff and VLAN configuration
> to iproute. Since the old link configuration was entirely ioctl based and
> mixing the two would be really ugly, this patch keeps the old ioctl stuff
> guarded by an ifdef (defaults to enabled) and probes for support for
> using RTM_NEWLINK. Tested to work properly on both old and patched kernel.
> 
> I've added a new -d[etail] flag to ip, the driver specific things are only
> printed when it is specified. I did this mainly because I'm not sure how
> careful we want to be not to confuse people using sed/awk/... on iproute
> output. I would prefer to have the information always shown, but I'll
> leave that decision up to you.
> 
> Changes since the last post:
> 
> - Only call link argument parsing function if arguments are present
> - Support xstats dumping
> - Add sanitized if_vlan.h file for VLAN flag definition
> - Support setting/changing VLAN flags
> 
> Please apply, thanks.

I'm putting out a new iproute2 next week. IF this is in mainline, it will
go in then. If not, then there will be a development branch
