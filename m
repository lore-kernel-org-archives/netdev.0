From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch v2 02/11] DM9000: Fixup blackfin after removing 2 resource usage
Date: Sun, 22 Jun 2008 21:35:32 +0100
Message-ID: <20080622203530.GB4050@solarflare.com>
References: <20080622201645.041001353@fluff.org.uk> <20080622201904.747948172@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bryan Wu <cooloney@kernel.org>,
	Laurent Pinchart <laurentp@cse-semaphore.com>
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.mbr-roch.zen.net.uk ([212.23.3.141]:55964 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753733AbYFVUfh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 16:35:37 -0400
Content-Disposition: inline
In-Reply-To: <20080622201904.747948172@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks wrote:
> From: Laurent Pinchart <laurentp@cse-semaphore.com>
> 
> The dm9000 driver accepts either 2 or 3 resources to describe the platform
> devices. The 2 resources case abuses the ioresource mechanism by passing
> ioremap()ed memory through the platform device resources. This patch removes
> converts boards that were using it to the 3 resources scheme.
[...]

This needs to be applied before the previous patch, otherwise there's
a point where these boards are broken.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
