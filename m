From: David Miller <davem@davemloft.net>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 13:29:28 -0700 (PDT)
Message-ID: <20060525.132928.115910730.davem@davemloft.net>
References: <20060525175947.GA29024@ipom.com>
	<200605251341.42204.bcook@bpointsys.com>
	<20060525192239.GB29024@ipom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcook@bpointsys.com, billfink@mindspring.com, jeff@garzik.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61153
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030401AbWEYU3Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 16:29:24 -0400
To: phil@ipom.com
In-Reply-To: <20060525192239.GB29024@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Phil Dibowitz <phil@ipom.com>
Date: Thu, 25 May 2006 12:22:39 -0700

> So at least, for the _current_ implimentations, this should have no
> performance impacts.

Regardless, I think this is something that userspace _can_
take care of reasonably and therefore has no buisness in the
kernel.

We do not duplicate functionality that is already possible
_unless_ it is incredibly difficult for userland to do so.
And in this case I do not think it is difficult for userland
to interpret the counters in the way you want it to.

So, major NACK on this stuff.
