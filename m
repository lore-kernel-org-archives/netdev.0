From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Sun, 10 Oct 2004 21:07:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041010210746.5e9438af.davem@davemloft.net>
References: <41633174.7070805@candelatech.com>
	<16740.17875.574967.11417@robur.slu.se>
	<41646587.7070401@candelatech.com>
	<41649425.1010102@candelatech.com>
	<20041006180826.4a092c71.davem@davemloft.net>
	<4165864A.2010805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4165864A.2010805@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 07 Oct 2004 11:09:14 -0700
Ben Greear <greearb@candelatech.com> wrote:

> How does the existing (non pktgen) architecture work for VLAN devices
> and stopping/starting the queues in the underlying devices?

VLAN devices are simply virtual devices.  There is a real netdev
structure backing them, and thus you can point queueing disciplines
et al. to them just like any other device.

So that's the idea, somehow tie pktgen to use the existing netdev_wake_queue()
callback mechanism.  All I am really saying is that qdiscs may be a method by
which to do this.
