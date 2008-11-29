From: Divy Le Ray <divy@chelsio.com>
Subject: Re: what is the expeted performance from a dual port 10G card ?
Date: Fri, 28 Nov 2008 22:30:27 -0800
Message-ID: <4930E183.9040700@chelsio.com>
References: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Raz <raziebe@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6876 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbYK2GaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 01:30:22 -0500
In-Reply-To: <5d96567b0811280511q1e3f7774j7eabce4810dae91a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Raz wrote:
> Hello
> I have been testing 10G ethernet cards , intel ixgbe, chelsio, tehuti
> and melanox . All are dual port cards.
> I have used pktgen to test it. A single cpu is mapped over a single
> interface (no neeed for MQ , which is quite bad anyway).
> Results:
> Intel gives: 13Gbps , 6.5 from each port.
> The rest give ~10 Gbps .
> Cards were tested on PCI-E x8 slot, on a supermicro x7DBI and
> supermicro 1025W-UR.
> 
> Am i to expect ~20Gbps from each card ?

Hi Raz,

For the rest, what is the load balance between the ports?
The Chelsio adapter shares the pci link between all ports.

Cheers,
Divy
