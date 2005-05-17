From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 11:50:20 -0700 (PDT)
Message-ID: <20050517.115020.119241057.davem@davemloft.net>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>
	<20050517.104947.112621738.davem@davemloft.net>
	<m1zmut7l5q.fsf@muc.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akepner@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@muc.de
In-Reply-To: <m1zmut7l5q.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@muc.de>
Date: Tue, 17 May 2005 20:38:25 +0200

> If anything it would be better as a per route flag.
> Then you could set it only for your local network
> where you know Gigabit happens and reordering might
> be avoidable in some cases.

This is still bogus, on SMP we get packet reordering all the time.

> P.S.: Arthur I think your arguments would have more
> force if you published the test program that demonstrates the
> corruption.

I already know it happens, and that IBM has gotten NFS corruption due
to this problem.  Using NFS over UDP is stupid.

I find it ironic to claim that folks are "stuck with UDP over NFS" but
were able to upgrade their networking technology to gigabit.
