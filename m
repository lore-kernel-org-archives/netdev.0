From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Infrahip] [PATCH] Host Identity Protocol
Date: Tue, 22 Mar 2005 09:20:02 -0800
Message-ID: <20050322092002.486fdf1c.davem@davemloft.net>
References: <42369919.9010203@cs.helsinki.fi>
	<Pine.GSO.4.58.0503201805240.1521@kekkonen.cs.hut.fi>
	<20050321.024241.67451836.yoshfuji@linux-ipv6.org>
	<20050320200356.5f8fa583.davem@davemloft.net>
	<Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, gurtov@cs.helsinki.fi, netdev@oss.sgi.com,
        infrahip@hiit.fi
To: Miika Komu <miika@iki.fi>
In-Reply-To: <Pine.GSO.4.58.0503221531020.19531@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 22 Mar 2005 16:08:31 +0200 (EET)
Miika Komu <miika@iki.fi> wrote:

> Yes, MIP6 and IKE signalling is handled in the userspace, but
> the same is not true for SCTP (lksctp).

SCTP is a network protocol used for data transfer.

HIP is a signalling mechanism used to setup configuration.

> engineering practise is to put everything in the userspace, unless there
> is good reason for putting it in to the kernelspace.
> 
> We don't currently have concrete measurements (comparing userspace and
> kernelspace approaches) to justify our kernel oriented approach, so we
> will have to get back to you later with some figures. If the results show
> that an userspace implementation is superior to a kernel based approach in
> terms of security or performance, we may have rewrite the code to the
> userspace. In the mean time, do you happen to know any good references
> where any userspace network protocol implementation has been compared and
> measured against a kernelspace implementation? It would be a good starting
> point for us.
> 
> I would like to mention that lksctp was implemented in the 2.6 kernel
> because of better performance and tighter integration to the socket API.
> We are dealing with similar issues with HIPL but seems like we need to
> justify the reasons by analyzing and measuring. In addition, security
> issues (DoS protection, user supplied public keys, etc) are taken pretty
> seriously in HIP and may benefit from a kernel oriented approach.
> 
> -- 
> Miika Komu              miika@iki.fi          http://www.iki.fi/miika/
