From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: bridge/brctl/ip
Date: Sun, 3 Apr 2016 00:39:06 +0200
Message-ID: <20160402223906.GI32554@lunn.ch>
References: <57001CFF.20508@biot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Bert Vermeulen <bert@biot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45089 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750766AbcDBWjJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2016 18:39:09 -0400
Content-Disposition: inline
In-Reply-To: <57001CFF.20508@biot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2016 at 09:26:55PM +0200, Bert Vermeulen wrote:
> Hi all,
> 
> I'm wondering about the current userspace toolset to control bridging in
> the Linux kernel. As far as I can determine, functionality is a bit
> scattered right now between the iproute2 (ip, bridge) and bridge-utils
> (brctl) tools:
> 
> - adding/deleting ports to/from bridge: brctl only

ip link set lan0 master br0

I think most of the normal operations can be done with iproute2.  What
might be missing is things like setting the forwarding delay, hello
time, etc.

   Andrew
