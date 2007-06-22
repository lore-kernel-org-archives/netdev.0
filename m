From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 0/7] CAN: Add new PF_CAN protocol family, try #3
Date: Fri, 22 Jun 2007 14:34:49 +0200
Message-ID: <467BC1E9.6030201@trash.net>
References: <20070622034452.28886.0@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62650 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbXFVMf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:35:28 -0400
In-Reply-To: <20070622034452.28886.0@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> * Use skb->iif instead of skb->cb to pass receiving interface from
>   raw_rcv() and bcm_rcv() up to raw_recvmsg() and bcm_recvmsg().


skb->iif doesn't necessarily point to the incoming network device
as seen seen by netif_receive_skb, for layered devices it currently
always points to the first interface that received a packet.

Its so far also only used for traffic classification, please explain
how you're using it and what values it is set to on which paths.
