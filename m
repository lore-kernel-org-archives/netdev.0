From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Ethernet Bridging: Enable Hardware Checksumming
Date: Wed, 18 May 2005 22:00:31 -0700 (PDT)
Message-ID: <20050518.220031.75189050.davem@davemloft.net>
References: <20050518235329.GA17946@us.ibm.com>
	<428BD7E7.5080207@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdmason@us.ibm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <428BD7E7.5080207@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Nivedita Singhvi <niv@us.ibm.com>
Date: Wed, 18 May 2005 17:03:51 -0700

> I think this is a good thing to have, gives us performance
> gain (equivalent to using/not using checksum offload) and
> has very little impact on the bridging layer, and is
> independent of the virtualization stuff..

I agree but keep in mind that when bridging over non-checksumming
devices it will be more expensive.  Especially for TCP.
