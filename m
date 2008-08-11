From: David Miller <davem@davemloft.net>
Subject: Re: tbench regression on each kernel release from 2.6.22 -> 2.6.28
Date: Mon, 11 Aug 2008 14:15:01 -0700 (PDT)
Message-ID: <20080811.141501.01468546.davem@davemloft.net>
References: <48A086B6.2000901@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751960AbYHKVPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 17:15:00 -0400
In-Reply-To: <48A086B6.2000901@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 11 Aug 2008 13:36:38 -0500

> It seems that the network stack becomes slower over time? Here is a list of
> tbench results with various kernel versions:
> 
> 2.6.22		3207.77 mb/sec
> 2.6.24		3185.66
> 2.6.25		2848.83
> 2.6.26		2706.09
> 2.6.27(rc2)	2571.03
> 
> And linux-next is:
> 
> 2.6.28(l-next)	2568.74
> 
> It shows that there is still have work to be done on linux-next. Too close to
> upstream in performance.
> 
> Note the KT event between 2.6.24 and 2.6.25. Why is that?

Isn't that when some major scheduler changes went in?  I'm not blaming
the scheduler, but rather I'm making the point that there are other
subsystems in the kernel that the networking interacts with that
influences performance at such a low level.  This includes the memory
allocator :-)
