From: David Miller <davem@davemloft.net>
Subject: Re: [PATC] sctp: various fixes
Date: Mon, 21 Jul 2008 08:05:35 -0700 (PDT)
Message-ID: <20080721.080535.194149976.davem@davemloft.net>
References: <20080718.230833.22196996.davem@davemloft.net>
	<20080719.224047.228019059.davem@davemloft.net>
	<48848B35.6050702@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753117AbYGUPFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 11:05:35 -0400
In-Reply-To: <48848B35.6050702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 21 Jul 2008 09:12:21 -0400

> David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Fri, 18 Jul 2008 23:08:33 -0700 (PDT)
> > 
> >> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> >> Date: Sat, 19 Jul 2008 00:26:45 -0400
> >>
> >>> This is a bunch of SCTP fixes that have accumlated over the past week or
> >>> so. 
> >> All applied, thanks Vlad.
> > 
> > Vlad, I had to add the following fix to the tree in order
> > to unbreak the build when CONFIG_HIGHMEM is enabled.
> > 
> 
> ahh...  since tcp isn't a module, it didn't trigger that.
> 
> Thanks Dave.  I didn't think about turning highmem off..

No problem, but the problematic case was turning highmem on :-)
