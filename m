From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: 17 Jan 2005 18:11:21 -0500
Message-ID: <1106003481.1035.35.camel@jzny.localdomain>
References: <20050116115431.GA13617@lst.de>
	 <1105885839.1097.573.camel@jzny.localdomain>
	 <20050117225946.GA11845@lst.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, pavlic@de.ibm.com,
        waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20050117225946.GA11845@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-17 at 17:59, Christoph Hellwig wrote:

> The problem is again that the OS instances don't talk to each
> (well they can, but not in the driver), so your demux code would
> have to move into the device firmware, and that'd probably change
> the device <-> OS interface completely.

qeth_qdio_input_handler() seems to know what "card" the packet came on,
no? 
Could you not use this information to select the proper netdevice?

Actually, how does that work? Each OS instance would get the same driver
invoked but you will never see any othe instances "cards"?

cheers,
jamal
