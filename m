From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast with multiple devices
Date: Mon, 26 May 2008 10:26:08 -0700
Message-ID: <OFD882A076.C7BD1EA7-ON88257455.005F4F9F-88257455.005FC5BC@us.ibm.com>
References: <alpine.LNX.1.10.0805261844210.19084@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:34083 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbYEZR0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 13:26:12 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4QHMTKc027151
	for <netdev@vger.kernel.org>; Mon, 26 May 2008 13:22:29 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4QHQBcO089116
	for <netdev@vger.kernel.org>; Mon, 26 May 2008 11:26:11 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4QHQBlj032128
	for <netdev@vger.kernel.org>; Mon, 26 May 2008 11:26:11 -0600
In-Reply-To: <alpine.LNX.1.10.0805261844210.19084@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most multicast applications don't use the routing table at all. Instead,
you should specify the particular interface you want, since the same
group number on different interfaces often isn't the same group.

You can use IP_MULTICAST_IF, SO_BINDTODEVICE, etc., and 
of course specify the interface in the IP_ADD_MEMBERSHIP call
for listeners.

                                                +-DLS

