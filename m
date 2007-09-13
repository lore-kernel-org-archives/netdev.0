From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 14:56:32 -0400
Message-ID: <46E987E0.2010605@garzik.org>
References: <adahclymos8.fsf@cisco.com> <46E97BB0.9030106@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37481 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557AbXIMS4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2007 14:56:37 -0400
In-Reply-To: <46E97BB0.9030106@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
> I was about to post v2 of my patch to avoid port space collisions with 
> the native stack.  Can we get that 2.6.24?  It is high priority IMO. 
> I've tried to solicit review on it, but I think folks are reluctant... ;-)

Well, if it involves /sharing/ port space with the native stack, i.e. 
where port 1234 is IB but 1235 is Linux, pretty much all the networking 
devs have NAK'd that approach AFAICS.

	Jeff



