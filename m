From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TCP NewCWV for Linux
Date: Thu, 20 Feb 2014 16:10:15 -0500 (EST)
Message-ID: <20140220.161015.892943239767681091.davem@davemloft.net>
References: <bbf79368e5d6514fbe6704a77b473407.squirrel@blake.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ziaul.hossain@abdn.ac.uk,
	gorry@erg.abdn.ac.uk
To: raffaello@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60135 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbaBTVKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 16:10:19 -0500
In-Reply-To: <bbf79368e5d6514fbe6704a77b473407.squirrel@blake.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raffaello@erg.abdn.ac.uk
Date: Thu, 20 Feb 2014 19:28:56 -0000

> This is a patch for newcwv a TCP sender-side modification,
> currently a work item at TCPM (TCP Maintenance and Minor extensions)
> at the IETF:
> 
> http://tools.ietf.org/search/draft-ietf-tcpm-newcwv-05
> 
> newcwv aims to supersede CWV (RFC2861) to provide better
> congestion control for rate-limited applications that use TCP.
> 
> We implemented it as a module that uses tcp_congestion_ops.
> The main changes are in "cong_avoid" before Reno cwnd control
> and at the start and end of Fast Retransmit:
> 
> 1) Before Reno algorithm we estimate at each ACK our pipeACK
> (update_pipeack) and decide to increase or not cwnd based on pipeack.
> 
> 2) At the start of FR we reset cwnd based on pipeACK, while
> at the end we further reduce pipeACK by the number of retransmissions.
> 
> I posted it here for you consideration to be included in net-next.

You need to provide a proper signoff, please see
linux/Documentation/SubmittingPatches
