From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [4/8]
Date: Thu, 19 Jul 2007 07:07:30 -0700
Message-ID: <20070719140730.GC12892@xyzzy.farnsworth.org>
References: <469EEE4B.2090008@realitydiluted.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Steven J. Hill" <sjhill@realitydiluted.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:2300 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965508AbXGSOON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2007 10:14:13 -0400
Content-Disposition: inline
In-Reply-To: <469EEE4B.2090008@realitydiluted.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 19, 2007 at 04:53:31AM +0000, Steven J. Hill wrote:
> Add main 642xx support to 'drivers/net/mv643xx_eth.c' file.

As Christoph said, this quantity of ifdefs really hurt the
maintainability.  Refactoring is needed.  Also, since in arch/powerpc
we want to have a single kernel support both MV64[34]60 and GT64260
(determined at runtime) and their register sets are so different, I
think the best approach is to have a separate module for the GT64260.

Also, please follow Documentation/SubmittingPatches.  Good subjects,
diffstats and "diff -p" would have been helpful in reviewing this series.

-Dale
