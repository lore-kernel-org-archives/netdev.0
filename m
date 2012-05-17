From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 16:21:52 -0400
Message-ID: <20120517202152.GB19321@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337285040-20848-1-git-send-email-nhorman@tuxdriver.com>
 <20120517.160937.586334759945738635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39487 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930Ab2EQUV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:21:59 -0400
Content-Disposition: inline
In-Reply-To: <20120517.160937.586334759945738635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 04:09:37PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu, 17 May 2012 16:04:00 -0400
> 
> > When I first wrote drop monitor I wrote it to just build monolithically.  There
> > is no reason it can't be built modularly as well, so lets give it that
> > flexibiity.
> > 
> > I've tested this by building it as both a module and monolithically, and it
> > seems to work quite well
> > 
> > Change notes:
> > 
> > v2)
> > * fixed for_each_present_cpu loops to be more correct as per Eric D.
> > * Converted exit path failures to BUG_ON as per Ben H.
> > 
> > v3)
> > * Converted del_timer to del_timer_sync to close race noted by Ben H.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, althrough it didn't apply cleanly to net-next.
> 

Apologies Dave, should have told you that I was carrying Joe P.'s cleanup patch
in my net-next tree as well:
http://marc.info/?l=linux-netdev&m=133727344816140&w=2

Since you noted that you had applied it, I applied it myself here.
Neil
