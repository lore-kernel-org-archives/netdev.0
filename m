From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mcp55 forcedeth woes
Date: Mon, 13 Apr 2009 16:45:48 -0700
Message-ID: <20090413164548.f241ec1e.akpm@linux-foundation.org>
References: <e3e0f4f0ca9fdce35c24b30559d10f31.squirrel@www.datavault.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: "Yan Seiner" <yan@seiner.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35241 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751319AbZDMXsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 19:48:45 -0400
In-Reply-To: <e3e0f4f0ca9fdce35c24b30559d10f31.squirrel@www.datavault.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(suitable cc's added)

On Mon, 13 Apr 2009 15:13:05 -0700 (PDT)
"Yan Seiner" <yan@seiner.com> wrote:

> I have a few Asus M2N-SLI deluxe mobos.  These mobos have the MCP55
> chipset and two 1gb ethernet ports.  Occasionally, and for no reason that
> I can figure out, these ports will die.  There are various ways to try and
> fix these; they seem to be about 50% effective, and approach something
> akin to voodoo.
> 
> Based on this discussion here:
> 
> http://patchwork.kernel.org/patch/16212/
> 
> I've gotten the ability to turn the ports on and off somewhat.
> 
> For port 0,
> 
> ethtool -s eth0 autoneg off speed 10 duplex full
> 
> turns on the link, and gets me half-duplex, 10mb/sec. Not much, granted.
> 
> ethtool -s eth0 autoneg off speed 100 duplex full
> 
> causes the link to go up and down on about a 2 second cycle.
> 
> ethtool -s eth0 autoneg on
> 
> causes the link to drop.
> 
> For port 1, the behavior is similar, except that I can get a stable 100
> mbit connection.
> 
> So the problem is in the autoneg code. It's a driver issue as this is
> reported widely to work under windows of various flavors.
> 
> I'm running 2.6.29.1; I'm ok with patching and building kernels, but I'm
> not a kernel hacker.
> 
> What, if anything, can I provide and do to fix this?
> 

