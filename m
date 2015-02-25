From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 net] e1000: add dummy allocator to fix race condition
 between mtu change and netpoll
Date: Wed, 25 Feb 2015 12:25:49 +0100
Message-ID: <20150225112549.GA24089@kria>
References: <1424862194-15770-1-git-send-email-sd@queasysnail.net>
 <1424863063.2553.52.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:2374 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244AbbBYLZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 06:25:55 -0500
Content-Disposition: inline
In-Reply-To: <1424863063.2553.52.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-25, 03:17:43 -0800, Jeff Kirsher wrote:
> On Wed, 2015-02-25 at 12:03 +0100, Sabrina Dubroca wrote:
> > @@ -4481,6 +4489,7 @@ next_desc:
> >         return cleaned;
> >  }
> >  
> > +
> >  /**
> >   * e1000_alloc_jumbo_rx_buffers - Replace used jumbo receive buffers
> >   * @adapter: address of board private structure
> 
> This added blank line is not needed or wanted.

Ouch, I noticed that too late. Sorry, I messed up.

Oh, BTW, e1000e has multiple allocators as well.  I haven't really
looked at them yet, and I don't have any HW to test.

-- 
Sabrina
