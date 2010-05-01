From: David Miller <davem@davemloft.net>
Subject: Re: OFT - reserving CPU's for networking
Date: Sat, 01 May 2010 15:13:33 -0700 (PDT)
Message-ID: <20100501.151333.199039545.davem@davemloft.net>
References: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
	<20100430.115715.216750975.davem@davemloft.net>
	<Pine.LNX.4.62.1005012222320.24624@wlug.westbo.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	ak@gargoyle.fritz.box, netdev@vger.kernel.org, andi@firstfloor.org,
	peterz@infradead.org
To: gandalf@mjufs.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34447
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753766Ab0EAWN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 18:13:28 -0400
In-Reply-To: <Pine.LNX.4.62.1005012222320.24624@wlug.westbo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Josefsson <gandalf@mjufs.se>
Date: Sat, 1 May 2010 22:31:05 +0200 (CEST)

> On Fri, 30 Apr 2010, David Miller wrote:
> 
>> Then we can do cool tricks like having the cpu spin on a mwait() on
>> the
>> network device's status descriptor in memory.
> 
> Can you have mwait monitor multiple cachelines for stores?

The idea is that if you have hundreds of cpus threads (several of my
machines do, and it's not too long before these kinds of boxes will be
common) in your machine you can spare one for each NIC.
