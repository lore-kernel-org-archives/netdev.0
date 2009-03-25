From: David Miller <davem@davemloft.net>
Subject: Re: igbvf: add new driver to support 82576 virtual functions
Date: Wed, 25 Mar 2009 14:34:04 -0700 (PDT)
Message-ID: <20090325.143404.244585946.davem@davemloft.net>
References: <9929d2390903250203u42b50b54j2db3464967d48702@mail.gmail.com>
	<20090325094742.GA7760@yzhao-otc.sh.intel.com>
	<49CA5788.2000402@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yu.zhao@intel.com, jeffrey.t.kirsher@intel.com,
	willy@linux.intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754885AbZCYVeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 17:34:17 -0400
In-Reply-To: <49CA5788.2000402@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 25 Mar 2009 09:10:48 -0700

> The problem isn't the SR-IOV patches it is a difference in
> architectures.  The x86/x86_64 architecture lets you be a bit more
> sloppy when it comes to including vmalloc.  I've seen it in the past
> with igb, and I suspect that is why we didn't catch this in testing.
> We just need to add a #include of vmalloc.h in ethtool.c and the
> issue should be fixed.

Yes, that was the problem.

I thought it was dead obvious from the build failure message.
What else could a lack of visible vmalloc() declaration mean? :-/
