From: Michele Baldessari <michele@acksyn.org>
Subject: Re: [net 1/2] sctp: add transport state in /proc/net/sctp/remaddr
Date: Tue, 28 Oct 2014 08:20:40 +0100
Message-ID: <20141028072040.GA6825@marquez.int.rhx>
References: <1414093721-14921-1-git-send-email-michele@acksyn.org>
 <20141027.185545.551457974536550723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org, dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palahniuk.acksyn.org ([5.9.7.26]:40535 "EHLO
	palahniuk.acksyn.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757775AbaJ1HUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 03:20:46 -0400
Content-Disposition: inline
In-Reply-To: <20141027.185545.551457974536550723.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Oct 27, 2014 at 06:55:45PM -0400, David Miller wrote:
> From: Michele Baldessari <michele@acksyn.org>
> Date: Thu, 23 Oct 2014 21:48:40 +0200
> 
> > It is often quite helpful to be able to know the state of a transport
> > outside of the application itself (for troubleshooting purposes or for
> > monitoring purposes). Add it under /proc/net/sctp/remaddr.
> > 
> > Signed-off-by: Michele Baldessari <michele@acksyn.org>
> 
> You can't change the layout of procfs files, applications parse
> these files and any modification can potentially break such tools.

Thanks for the review. I assumed that extending a procfile by adding
a column at the end is ok and that tools must cope with that anyway.
(i.e. like it's been done in f19c29e3e391a66a273e9afebaf01917245148cd)

> Secondly, even if this change were acceptable, targetting this
> change at anything other than the net-next tree is not appropriate
> because it is a new feature.

Ok. Unless you are against adding a column, I'll resubmit to net-next
later this week.

Thanks,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
