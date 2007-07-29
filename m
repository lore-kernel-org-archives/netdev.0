From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Sat, 28 Jul 2007 22:33:39 -0700 (PDT)
Message-ID: <20070728.223339.85409302.davem@davemloft.net>
References: <46A8003F.1050208@garzik.org>
	<20070725.190245.68070169.davem@davemloft.net>
	<46AB862C.9040507@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	hadi@cyberus.ca, rusty@rustcorp.com.au
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53141
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752979AbXG2Fdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jul 2007 01:33:39 -0400
In-Reply-To: <46AB862C.9040507@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Sat, 28 Jul 2007 14:08:44 -0400

> That's a performance/parallelization regression from current NAPI :(

That's not true since current NAPI will only run on one cpu, the
one that the interrupt triggers on.

The existing cases that are not guarding the sequence to be
atomic are racy, and in a way which is very hard to debug when
it triggers and the device just appears dead.
