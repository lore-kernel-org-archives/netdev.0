From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Thu, 27 Sep 2007 12:18:02 -0700 (PDT)
Message-ID: <20070927.121802.102416572.davem@davemloft.net>
References: <20070920184533.3795.5@janus.isnogud.escape.de>
	<m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
	<m13ax0m6ca.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, netdev@vger.kernel.org, kaber@trash.net,
	tglx@linutronix.de, oliver@hartkopp.net,
	oliver.hartkopp@volkswagen.de, urs.thuermann@volkswagen.de,
	dlezcano@fr.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757067AbXI0TSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:18:02 -0400
In-Reply-To: <m13ax0m6ca.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 27 Sep 2007 10:16:37 -0600

> 
> I guess in particular IFF_LOOPBACK means that all packets from
> a device will come right back to the current machine, and go
> nowhere else.
> 
> That usage sounds completely different then the CAN usage which
> appears to mean.  Broadcast packets will be returned to this machine
> as well as being sent out onto the wire.

It's bogus and it should be removed from the CAN code, they
can add some other attribute to achieve their goals.
