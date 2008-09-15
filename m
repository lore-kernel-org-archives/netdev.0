From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 18:38:07 -0400
Message-ID: <20080915223807.GC15421@havoc.gtf.org>
References: <20080915204543.GD3994@havoc.gtf.org> <20080915.141442.139271313.davem@davemloft.net> <20080915215307.GA10340@alpha.franken.de> <20080915.151125.93659986.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tsbogend@alpha.franken.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:38368 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753273AbYIOWiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 18:38:09 -0400
Content-Disposition: inline
In-Reply-To: <20080915.151125.93659986.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 03:11:25PM -0700, David Miller wrote:
> There are a lot of clean and good fixes, but that is not the
> criteria for outside-of-the merge-window submissions right now.
> 
> Linus has made this clear.

He continues to take non-regression fixes and minor cosmetic commits
from other trees.

The basic idea is to BALANCE the lateness of -rc with the seriousness of
the problem being fixed, and the technical complexity of the fix itself.

The later the -rc, the more you need to take into account how likely it
is to create additional problems.  But did you READ the patches and
extended commit descriptions, to see if additional problems were likely?

Late -rc does not mean "no bug fixes at all except regressions" if you
look at the commits going into the kernel tree.

Late -rc does not mean putting off memory corruption fixes for 6 months.

	Jeff



