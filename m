From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Mon, 17 Jan 2005 23:59:46 +0100
Message-ID: <20050117225946.GA11845@lst.de>
References: <20050116115431.GA13617@lst.de> <1105885839.1097.573.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, pavlic@de.ibm.com,
        waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105885839.1097.573.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 09:30:40AM -0500, jamal wrote:
> I could be missing something:
> Its almost like the "cards" in these drivers deserve to be their own
> netdevices to begin with. In other words the qeth approach itself seems
> to be a hack to begin with. 
> Should be along the lines:
> --->Physical netdevice
>   -->some demux code to select instance
>     --> Virtual netdevice specific to OS instance
>         ---> standard linux path

The problem is again that the OS instances don't talk to each
(well they can, but not in the driver), so your demux code would
have to move into the device firmware, and that'd probably change
the device <-> OS interface completely.
