From: Dan Williams <dcbw@redhat.com>
Subject: Re: Please pull 'libertas' branch of wireless-2.6
Date: Wed, 30 May 2007 11:28:48 -0400
Message-ID: <1180538928.17163.10.camel@xo-28-0B-88.localdomain>
References: <20070529183347.GD3496@tuxdriver.com>
	 <465D8538.8070507@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794AbXE3PZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 11:25:03 -0400
In-Reply-To: <465D8538.8070507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-30 at 10:07 -0400, Jeff Garzik wrote:
> John W. Linville wrote:
> > Lots of stuff here...probably best for 2.6.23...
> 
> Is this best for Linux users... or just easy for developers?
> 
> Won't putting off all these fixes until 2.6.23 leave the driver released 
> in 2.6.22 in shoddy shape?

Not really; it more or less works there.  What's gone on since then is
general driver cleanup (Christoph's comments and more), splitting the
driver so that other bus types can use it (SDIO for example once
Pierre's SDIO patches get upstream), wireless extensions fixes, etc.

> libertas is upstream now, so we cannot pretend that the driver is 
> completely independent from upstream release cycles and maintenance.

True, but some of the stuff in here I didn't think would be suitable
during an -rc cycle, for example the driver splitting and the cleanups
that don't impact function at all, but are good to do nonetheless.

> libertas fixes should go upstream immediately, since we are in a bugfix 
> cycle, and since libertas (from upstream perspective) is about to make 
> its big debut on the world stage.

If you think all the bits from this should just go to 2.6.22, that's
fine with me.  But I don't feel comfortable making that call given what
I thought were the constraints on pushing changes through during an rc
cycle.  When the merge window was open, we backported critical bug fixes
and necessary merge-requirement cleanups to the code in linville's tree,
but avoided changes that didn't impact function.

Dan


