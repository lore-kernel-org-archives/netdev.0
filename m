From: Baruch Even <baruch@ev-en.org>
Subject: Re: way of figuring out total number of retransmitted packets on a
	TCP socket?
Date: Wed, 20 Oct 2004 14:25:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098278702.16002.7.camel@baruch.hamilton.local>
References: <20041020130134.GC24757@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041020130134.GC24757@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-20 at 14:01, Lennert Buytenhek wrote:
> Hi,
> 
> I'm looking for a way of counting the total number of retransmitted packets
> sent on a TCP connection.  I tried querying TCP_INFO:tcpi_retransmits, but
> that seems to be not the metric I'm looking for.
> 
> Anyone got any ideas?  (Apart from using tcpdump+tcptrace.)

The web100 patch gives you that, but it's not part of the basic kernel.
You can find it in web100.org and you also need the user mode utilities
to get the information.

Baruch
