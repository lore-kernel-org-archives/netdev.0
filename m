From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: RFC: ethtool support for n-tuple filter programming
Date: Sun, 08 Nov 2009 21:49:21 -0800
Message-ID: <1257745762.2609.5.camel@ppwaskie-mobl2>
References: <1257533841.2610.12.camel@ppwaskie-mobl2>
	 <20091107.202712.222562359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:54398 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbZKIFtR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 00:49:17 -0500
In-Reply-To: <20091107.202712.222562359.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-07 at 21:27 -0700, David Miller wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Fri, 06 Nov 2009 10:57:21 -0800
> 
> > Any comments, thoughts, suggestions, or ideas are welcome.
> 
> We can use the existing datastructures and defines used for
> ETHTOOL_GRX* for new ethtool commands that do filtering.
> 
> NIU can filter on these tuples too.

Are you suggesting to extend the flow hash stuff that is already in
ethtool (same ioctl)?  If so, that makes sense.  I'll go ahead and get
some patches together for review.

Thanks,
-PJ

