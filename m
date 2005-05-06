From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 20:30:52 -0700
Message-ID: <20050505203052.059125eb.davem@davemloft.net>
References: <20050505153532.30159bd5.davem@davemloft.net>
	<200505060320.j463KvVG013576@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Leonid Grossman" <leonid.grossman@neterion.com>
In-Reply-To: <200505060320.j463KvVG013576@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 May 2005 20:20:56 -0700
"Leonid Grossman" <leonid.grossman@neterion.com> wrote:

> We will be testing on 10GbE NICs in the next couple weeks; will let you
> know.
> BTW - any plans for IPv6 support? 

What exactly does your NIC expect?  Do you use the
NETIF_F_HW_CSUM flag to indicate generic checksumming support?
Otherwise, there is no other way to support ipv6 checksum offload
at the moment, and that is a requirement for ipv6 TSO.

For TSO, the ipv6 header handling seems very non-trivial.
What is supposed to happen in cases where certain optional
extension headers should be present in some of the frames
but not the others?

A specification of how your NIC support ipv6 TSO is necessary
in order for support to be written, see?  Seems like you are
the most qualified person to write the support, therefore :-)
Really, it isn't that hard and you have something on which
to test whatever you write, whereas I don't.
