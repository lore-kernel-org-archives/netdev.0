From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: unintended ipv4 broadcast policy change
Date: Fri, 24 Jun 2011 10:01:21 -0700
Message-ID: <20110624100121.63bbc93a@nehalam.ftrdhcpuser.net>
References: <20110623081614.213a432f@nehalam.ftrdhcpuser.net>
	<20110623.134504.1261579649197526589.davem@davemloft.net>
	<20110623170137.69054c83@s6510.ftrdhcpuser.net>
	<20110623.140821.674961342350404546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45132 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750850Ab1FXRB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 13:01:26 -0400
In-Reply-To: <20110623.140821.674961342350404546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Jun 2011 14:08:21 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 23 Jun 2011 17:01:37 -0400
> 
> > Standard Debian stable (Squeeze) installation.
> > $ dpkg -S /sbin/dhclient
> > isc-dhcp-client: /sbin/dhclient
> 
> I bet what happens is that since it isn't reading from
> the AF_PACKET socket the receive queue just fills up
> and it's just in the kernel dropping packets in
> packet_spkt_rcv().

I don't think that is correct, just instrumented /proc/net/packet
to add receive queue length is stuck at 0. The packets are getting
dropped somewhere else.



sk               RefCnt Type Proto  Iface R Rmem   User   Inode  Count
ffff880327038000 3      10   0003   3     1 0      0      5881   0
