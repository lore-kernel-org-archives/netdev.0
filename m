From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: The mystery of optimistic ipv6 DAD handling
Date: Wed, 28 Dec 2011 19:00:44 -0500
Message-ID: <20111229000044.GA7513@hmsreliant.think-freely.org>
References: <20111228151928.GA12025@neilslaptop.think-freely.org>
 <20111228.133933.866545698956085305.davem@davemloft.net>
 <20111228192150.GA16499@neilslaptop.think-freely.org>
 <20111228.143812.206477268839022030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36778 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab1L2AAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 19:00:48 -0500
Content-Disposition: inline
In-Reply-To: <20111228.143812.206477268839022030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 28, 2011 at 02:38:12PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 28 Dec 2011 14:21:50 -0500
> 
> > Clearly I misread the RFC the first time through and the test as it existed is
> > incorrect.  I'm wondering though if what we need is a way to lookup if we've
> > received a RA on the interface, and check to see if it has a source link layer
> > option attached to it.
> 
> Yes, we could implement this with a new neigh lookup routine, that allows
> keying on device pointer and flags.
> 
> So in this case we'd pass the device and NTF_ROUTER.  If the lookup returns
> non-NULL then we've seen an RA with SLLAO specified.
> 

Agreed.  If its ok with you I'll start working on that in a few days, once we
get through the holidays here.  

Happy New Year!
Best
Neil
