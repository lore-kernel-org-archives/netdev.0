From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] mlx4: Added interrupts test support
Date: Thu, 01 Oct 2009 22:27:15 -0700 (PDT)
Message-ID: <20091001.222715.166183229.davem@davemloft.net>
References: <4AC4BD9A.2050101@mellanox.co.il>
	<adaeipmqxmv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.co.il, netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51906
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755117AbZJBF04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 01:26:56 -0400
In-Reply-To: <adaeipmqxmv.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Thu, 01 Oct 2009 20:32:08 -0700

> This feels like a pretty risky thing to do while the device might be
> handling all sorts of other traffic at the same time.  Are you sure
> there are no races you expose here?  Have you actually seen cases where
> the interrupt test during initialization works but then this test
> catches a problem?  (My experience has been that if any MSI-X interrupts
> work from a device, then they'll all work)

I would suggest only allowing the test while the interface is down.
That way the test has exclusive control of the IRQ.
