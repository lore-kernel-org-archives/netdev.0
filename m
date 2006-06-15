From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Thu, 15 Jun 2006 00:52:34 -0400
Message-ID: <1150347154.26487.30.camel@dv>
References: <20060610175010.GA4617@divinity>
	 <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com>
	 <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity>
	 <20060612152434.GA14851@tuxdriver.com>
	 <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Faidon Liambotis <faidon@cube.gr>,
	Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:30437 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750782AbWFOEwl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 00:52:41 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FqjqR-0001wW-Ny
	for netdev@vger.kernel.org; Thu, 15 Jun 2006 00:52:39 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0606121710j5be6ce0fhac71b69bf4dce2c2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-06-12 at 17:10 -0700, Jesse Brandeburg wrote:
> my problem is that for my prism 2 adapter both drivers are loaded at
> which point neither of them works.  I'm running FC5, and i have to
> keep removing the orinoco*.ko files to keep them from loading, so I'm
> all for this patch.

I believe the right solution would be to do it in userspace.  The kernel
should not be making decisions which driver is _better_ for the device.
I'm yet to see any serious arguments why the kernel should be doing it.

As for non-working driver, this should be reported with sufficient
details.  I haven't seen any detailed reports of this problem.

-- 
Regards,
Pavel Roskin

