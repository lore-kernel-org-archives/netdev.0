From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 17:04:30 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161659440.7855@qirst.com>
References: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
	vladislav.yasevich@hp.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:40618 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbZDPVLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 17:11:49 -0400
In-Reply-To: <OF0F292ED0.17C084A6-ON8825759A.00718BFC-8825759A.00730FD8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, David Stevens wrote:

> must be a new app, is fine. Adding a socket option as part of a port
> is no great hurdle, and I'm guessing you aren't trying to run a Solaris
> binary on Linux. So what's the problem?

Guess its the obvious: Software should run on multiple OSes without
too much special casing. Linux is the only special case that I am aware of
that misbehaves.

Adding a socket is no easy thing given the architecture of the software
(and of other software) that did not consider that Linux faithfully
replicating bugs from 25 years ago that no longer exist in other OSes.

Cannot imagine there to be too much software out there that relies on this
strange behavior. Otherwise the software would not work on various other
platforms.

Can you give us a list of products that verifiably rely on the current
behavior?
