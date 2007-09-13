From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ofa-general] InfiniBand/RDMA merge plans for 2.6.24
Date: Thu, 13 Sep 2007 14:12:35 -0700
Message-ID: <adalkbal16k.fsf@cisco.com>
References: <adahclymos8.fsf@cisco.com>
	<46E97BB0.9030106@opengridcomputing.com> <46E987E0.2010605@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Wise <swise@opengridcomputing.com>,
	general@lists.openfabrics.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:53428 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842AbXIMVMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2007 17:12:37 -0400
In-Reply-To: <46E987E0.2010605@garzik.org> (Jeff Garzik's message of "Thu, 13 Sep 2007 14:56:32 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Well, if it involves /sharing/ port space with the native stack,
 > i.e. where port 1234 is IB but 1235 is Linux, pretty much all the
 > networking devs have NAK'd that approach AFAICS.

Just to be clear, InfiniBand has no problem; the issue is port
collisions involving iWARP connections.

 - R.
