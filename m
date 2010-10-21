From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] tipc: revert some previously ABI breaking changes to the
 user space tipc interface
Date: Thu, 21 Oct 2010 11:51:17 -0400
Message-ID: <20101021131844.GA13908@hmsreliant.think-freely.org>
References: <1287659176-14504-1-git-send-email-nhorman@tuxdriver.com>
 <4CC03ACE.7030308@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net,
	luca@llucax.com.ar
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46770 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753284Ab0JUPv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:51:28 -0400
Content-Disposition: inline
In-Reply-To: <4CC03ACE.7030308@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 21, 2010 at 09:06:22AM -0400, Paul Gortmaker wrote:
> On 10-10-21 07:06 AM, nhorman@tuxdriver.com wrote:
> > Based on discussions with Leandro Lucarella and Jon Maloy, it appears we've
> > managed to break the TIPC user space ABI.  While it would be really nice to have
> > some level of consistency in regards to on the wire byte order, we can't do that
> > if it breaks user space.  This patch series reverts the offending patches that
> > caused this, and puts us back in a state that allows user space to work
> > properly.  We can now go back and look at methods to get consistent on the wire
> > byte order while maintaining host byte order in the user space API.
> 
> Thanks Neil for working with Jon and Leandro on this and getting
> a fix out quickly (faster than I could have, for sure.)
> 
> Paul.
> 
Not to worry, and apologies for the noise.  I missed the possibility previously
that received messages in that path could come in from the local client as well
as over the wire.  As soon as I get a few other things out of the way, I'll take
a second look at this.  It would be really nice if we could create a consisten
byte order on the wire without busting userspace.

Neil

> > 
> > Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> 
> 
