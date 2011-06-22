From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Steps to integrate new 40G Network driver to the kernel tree
Date: Wed, 22 Jun 2011 01:14:13 +0100
Message-ID: <1308701653.3093.113.camel@localhost>
References: <4DA8D9F6.2070908@oracle.com> <20110415175429.5e91fb59@nehalam>
	 <4E012D80.4090907@oracle.com>  <4E012EF1.3050005@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37216 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab1FVAOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 20:14:18 -0400
In-Reply-To: <4E012EF1.3050005@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 16:53 -0700, Joyce Yu - System Software wrote:
> Since it is a new driver, shall I follow the "Submitting Drivers for the 
> Linux Kernel" Doc? The driver is ready and passed all our QA cycles. I  
> have three source base, one is for 2.6.16 and 2.6.18 (for RHL 5.X and 
> SLES 10 SP3) , one is for 2.6.32 (For RHL 6.X, SLES11SP1), one for 
> 2.6.27 (For SLES11). Can it be integrated to the 2.6.18 and 2.6.32 tree? 
> or it has to be in the latest 2.6.39 or later?

There are 'longterm' branches for Linux 2.6.27 and 2.6.32, but they
don't include new drivers.  If you want your driver to go into existing
distributions then you have to talk to the distributors.  They will
generally tell you that your driver should be accepted in mainline Linux
first.  So you should first submit a driver based on David Miller's
net-2.6 tree (targetting 3.0) or net-next-2.6 (targetting 3.1).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

