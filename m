From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Thu, 27 Sep 2007 10:16:37 -0600
Message-ID: <m13ax0m6ca.fsf@ebiederm.dsl.xmission.com>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184533.3795.5@janus.isnogud.escape.de>
	<m1hclgm7dr.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54394 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbXI0QRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 12:17:36 -0400
In-Reply-To: <m1hclgm7dr.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's
	message of "Thu, 27 Sep 2007 09:54:08 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I guess in particular IFF_LOOPBACK means that all packets from
a device will come right back to the current machine, and go
nowhere else.

That usage sounds completely different then the CAN usage which
appears to mean.  Broadcast packets will be returned to this machine
as well as being sent out onto the wire.

Eric
