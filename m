From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 checksum errors
Date: Thu, 18 Feb 2010 09:38:43 -0800
Message-ID: <20100218093843.0c9b7f07@nehalam>
References: <faefb3f11002180245q734c501o23488c31bfb67211@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: Roman Tsisyk <roman@tsisyk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41143 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754459Ab0BRRis (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 12:38:48 -0500
In-Reply-To: <faefb3f11002180245q734c501o23488c31bfb67211@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Feb 2010 16:45:59 +0600
Roman Tsisyk <roman@tsisyk.com> wrote:

> We have motherboard with Marvell 88E8056 ethernet controllers.
> ------
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056
> PCI-E Gigabit Ethernet Controller (rev 14)
> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056
> PCI-E Gigabit Ethernet Controller (rev 14)
> ------
> 
> It is used for routing network packets between two interfaces. This
> system has been tested for several days using pktgen with different
> packet size and bandwidth settings and found problem similar to
> http://marc.info/?l=linux-net&m=121967539203137&w=2
> Firmware was updated according to that thread instructions, thereafter
> rev. changed from 12 to 14. But interfaces periodically starting to
> loose a large number of packets and netdev_rx_csum_fault threw.
> 

It would be good to know the size of packets and the state of the
receive status ring when the receive checksum error occurred.
This would require additional instrumentation.

What is your kernel configuration? What kernel version?
There were several recent stability fixes for sky2 driver relating
to DMA mapping.



-- 
