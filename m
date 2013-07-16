From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [net PATCH] atl1e: unmap partially mapped skb on dma error and
 free skb
Date: Tue, 16 Jul 2013 16:48:49 -0400
Message-ID: <20130716204849.GE8940@hmsreliant.think-freely.org>
References: <1373986181-15797-1-git-send-email-nhorman@tuxdriver.com>
 <20130716.121125.1312991211924388920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38029 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933670Ab3GPUtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:49:03 -0400
Content-Disposition: inline
In-Reply-To: <20130716.121125.1312991211924388920.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 16, 2013 at 12:11:25PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 16 Jul 2013 10:49:41 -0400
> 
> > Ben Hutchings pointed out that my recent update to atl1e:
> > 
> > commit 352900b583b2852152a1e05ea0e8b579292e731e
> > Author: Neil Horman <nhorman@tuxdriver.com>
> > Date:   Fri Jul 12 10:58:48 2013 -0400
> > 
> >     atl1e: fix dma mapping warnings
> > 
> > Was missing a bit of code.  Specifically it reset the hardware tx ring to its
> > origional state when we hit a dma error, but didn't unmap any exiting mappings
> > from the operation.  This patch fixes that up.  It also remembers to free the
> > skb in the event that an error occurs, so we don't leak.  Untested, as I don't
> > have hardware.  I think its pretty straightforward, but please review closely.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, but please refer to commits in the form "$SHA1ID ("Commit message
> header line")", I fixed it up for you this time.
> 
copy, thanks dave
Neil
