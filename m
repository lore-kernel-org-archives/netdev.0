From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Wed, 13 Dec 2006 15:07:24 +1100
Message-ID: <1165982844.11914.125.camel@localhost.localdomain>
References: <5cac192f0611290256l7067ce21r39881486f6e21289@mail.gmail.com>
	 <5cac192f0611291437g26fefebdocdacbb0cd2aa2fdd@mail.gmail.com>
	 <1165979533.11914.114.camel@localhost.localdomain>
	 <20061212.200334.59657088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49108 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932592AbWLMEHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 23:07:32 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061212.200334.59657088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-12-12 at 20:03 -0800, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Wed, 13 Dec 2006 14:12:13 +1100
> 
> > David, could that be the pause stuff not working properly ?
> 
> It could be, but if the tg3 says flow control is up in the kernel logs
> things ought to be OK.

tg3 says

tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is on for TX and on for RX.

but sungem says

eth0: Link is up at 1000 Mbps, full-duplex.
eth0: Pause is disabled

Hrm... I suppose I need to dig more. No time to do that today though.

Ben.


