From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [patch v2 02/11] DM9000: Fixup blackfin after removing 2
	resource usage
Date: Mon, 23 Jun 2008 10:24:07 +0100
Message-ID: <20080623092407.GD26276@fluff.org.uk>
References: <20080622201645.041001353@fluff.org.uk> <20080622201904.747948172@fluff.org.uk> <20080622203530.GB4050@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben-linux@fluff.org>, netdev@vger.kernel.org,
	jeff@garzik.org, Bryan Wu <cooloney@kernel.org>,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:50503 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758357AbYFWJYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 05:24:13 -0400
Content-Disposition: inline
In-Reply-To: <20080622203530.GB4050@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 22, 2008 at 09:35:32PM +0100, Ben Hutchings wrote:
> Ben Dooks wrote:
> > From: Laurent Pinchart <laurentp@cse-semaphore.com>
> > 
> > The dm9000 driver accepts either 2 or 3 resources to describe the platform
> > devices. The 2 resources case abuses the ioresource mechanism by passing
> > ioremap()ed memory through the platform device resources. This patch removes
> > converts boards that were using it to the 3 resources scheme.
> [...]
> 
> This needs to be applied before the previous patch, otherwise there's
> a point where these boards are broken.

There may be a small overlap, but I'd much rather fix the abuse than
actually leave it in there much longer. The fixup patch has been cc'd
to the blackfin maintainer, so any breakage will be minimal (and will
also be clearly marked, it isn't as if the driver will just fail to
work; there is a clear error being printed and it will gracefully
exit).

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
