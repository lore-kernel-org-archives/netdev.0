From: David Miller <davem@davemloft.net>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Thu, 21 Jun 2007 12:13:05 -0700 (PDT)
Message-ID: <20070621.121305.109899848.davem@davemloft.net>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, jeff@garzik.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50297
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753267AbXFUTMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 15:12:47 -0400
In-Reply-To: <m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 21 Jun 2007 13:08:12 -0600

> However this just seems to allow a card to decode multiple mac addresses
> which in some oddball load balancing configurations may actually be
> useful, but it seems fairly limited.
> 
> Do you have a specific use case you envision for this multiple mac
> functionality?

Virtualization.

If you can't tell the ethernet card that more than 1 MAC address
are for it, you have to turn the thing into promiscuous mode.

Networking on virtualization is typically done by giving each
guest a unique MAC address, the guests have a virtual network
device that connects to the control node (or dom0 in Xen parlace)
and/or other guests.

The control node has a switch that routes the packets from the
guests either to other guests or out the real ethernet interface.

Each guest gets a unique MAC so that the switch can know which
guest an incoming packet is for.
