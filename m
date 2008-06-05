From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: multicast with multiple devices
Date: Thu, 5 Jun 2008 11:54:54 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0806051154300.29055@fbirervta.pbzchgretzou.qr>
References: <OFD882A076.C7BD1EA7-ON88257455.005F4F9F-88257455.005FC5BC@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:32862 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756870AbYFEJy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 05:54:56 -0400
In-Reply-To: <OFD882A076.C7BD1EA7-ON88257455.005F4F9F-88257455.005FC5BC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2008-05-26 19:26, David Stevens wrote:

>Most multicast applications don't use the routing table at all. Instead,
>you should specify the particular interface you want, since the same
>group number on different interfaces often isn't the same group.
>
>You can use IP_MULTICAST_IF, SO_BINDTODEVICE, etc., and 
>of course specify the interface in the IP_ADD_MEMBERSHIP call
>for listeners.

But what if you do not have an application to begin with?
Does not the kernel do autonomic forwarding of multicast
like it does for unicast?
