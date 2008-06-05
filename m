From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast with multiple devices
Date: Thu, 5 Jun 2008 11:48:24 -0700
Message-ID: <OF0926BA3A.E49D3C0F-ON8825745F.0066E9B1-8825745F.00674E75@us.ibm.com>
References: <alpine.LNX.1.10.0806052024240.29055@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:37617 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbYFESs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 14:48:29 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m55ImRli025536
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 14:48:27 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m55ImQxN087558
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 12:48:26 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m55ImQD3024404
	for <netdev@vger.kernel.org>; Thu, 5 Jun 2008 12:48:26 -0600
In-Reply-To: <alpine.LNX.1.10.0806052024240.29055@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No, multicast routing requires knowledge of group
membership information on remote networks, which
is the job of multicast routing protocols.

If the kernel is originating a multicast packet, it needs
to select the interface, just as applications should.
Otherwise, which one it gets is arbitrary, and it matters.

                                        +-DLS

