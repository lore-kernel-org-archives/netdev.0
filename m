From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net: stmmac: add drop transmit status feature
Date: Wed, 12 Apr 2017 15:52:39 +0200
Message-ID: <20170412135239.GD32596@lunn.ch>
References: <f43dda26d3c43fdf19d6872306741c16b635558c.1491989111.git.jpinto@synopsys.com>
 <20170412115643.GA32596@lunn.ch>
 <d5e99129-eef0-1d15-7277-e3c82435bf9f@synopsys.com>
 <20170412131008.GC32596@lunn.ch>
 <37cc8294-5514-ed02-9b41-86f8cc9c20ad@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joao Pinto <Joao.Pinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56488 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751123AbdDLNwp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 09:52:45 -0400
Content-Disposition: inline
In-Reply-To: <37cc8294-5514-ed02-9b41-86f8cc9c20ad@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> My setup is FPGA based, so it will have lower performance values.
> >> Iperf results with
> >>   "Drop Transmit Status" set: ~650Mbps.
> >>   "Drop Transmit Status" unset: ~450Mbps.
> > 
> > What percentage of your customers use FPGAs? When i look at the users
> > of this driver, i see ST, Allwinner, Rockchip, Meson, etc. So silicon,
> > not FPGA. Does it make sense to do performance measurements on FPGA,
> > when you say it has lower performance?
> 
> I don't understand your question. Synopsys is an IP vendor, so all recent IPs
> are available for prototyping as you can understand and so early development is
> done using a FPGA.

Sure, early development on FPGA makes sense. But my guess is, > 95% of
the devices running this driver are silicon, not FPGA. The customers
you sell the IP to want to know that the driver is going to work well
on their silicon, not your internal FPGA development setup. The kernel
community want a warm fuzzy feeling that you care about the real
devices out in the wild using this driver. So if you could say, "I
tested on a STM DISCO devel board, and performance went up 20%, an
RK3288 devel board and got 18% performance boost, and a Merrii A80
Optimus Board showed 22% improvements", we would have a lot better
feeling about these patches.

	Andrew
