From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] rndis: remove private wrapper of __constant_cpu_to_le32
Date: Wed, 11 Feb 2009 14:16:13 -0800
Message-ID: <1234390573.5566.13.camel@brick>
References: <1234389410.5566.5.camel@brick>
	 <200902111412.18233.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, John Linville <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.186]:15953 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbZBKWRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 17:17:52 -0500
Received: by rn-out-0910.google.com with SMTP id k40so467343rnd.17
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2009 14:17:51 -0800 (PST)
In-Reply-To: <200902111412.18233.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-11 at 14:12 -0800, David Brownell wrote:
> On Wednesday 11 February 2009, Harvey Harrison wrote:
> > Use cpu_to_le32 directly as it handles constant folding now, replace direct
> > uses of __constant_cpu_to_{endian} as well.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> Acked-by: David Brownell <dbrownell@users.sourceforge.net>
> 
> ... though I'm trusting you that constant folding really *does* work
> now, as it didn't when all this code was first written.  Easily enough
> seen if it doesn't:  build on big-endian HW will break on all the
> "case cpu_to_le32(constant):" branches.  ;)

Yes, and large parts of the kernel are already moved to using the base versions
already.  I fixed the constant-folding bits during the creation/consolidation
of linux/swab.h

Harvey

