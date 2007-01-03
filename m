From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 3 Jan 2007 15:56:39 -0800
Message-ID: <OFDA4F9DE3.74AD3B77-ON88257258.00832CAB-88257258.00838732@us.ibm.com>
References: <459C3DB8.6090603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>, jarkao2@o2.pl,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:38848 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932181AbXACX4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 18:56:42 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id l03NufNO029276
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 18:56:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l03NufaZ545046
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 16:56:41 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l03NueKY022385
	for <netdev@vger.kernel.org>; Wed, 3 Jan 2007 16:56:41 -0700
In-Reply-To: <459C3DB8.6090603@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, sounds good.

By the way, I think you can probably hit it more often if you have
something on the virtual network sending lots of multicast traffic while
you're creating the interface. That'll increase the odds that you'll
get into ip_check_mc() with a partially initialized in_dev.

You can use "ping -I intfX 224.0.0.1" (e.g.) to generate multicast
traffic, though you'd want more than one. :-)

                                                +-DLS

