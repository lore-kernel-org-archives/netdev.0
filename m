From: "David S. Miller" <davem@davemloft.net>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 15:32:28 -0800
Message-ID: <20050228153228.0c5cb46d.davem@davemloft.net>
References: <20050224155906.73890361@dxpl.pdx.osdl.net>
	<20050227202011.5ccefb22.davem@davemloft.net>
	<42235114.3070109@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mostrows@speakeasy.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <42235114.3070109@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Feb 2005 09:12:52 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The original sk98lin attempted to receive hardware checksumming
> but never actually turned it on.

Because there is a bug in the chip wherein checksums can be
miscalculated.  I forget the details, but I do remember that
you can't enable checksumming safely because of this.

In drivers/net/sk98lin/skcsum.c it mentions this:

 * Note:
 *      There is a bug in the GENESIS ASIC which may lead to wrong checksums.

I know this comment is above the send checksum routine, but I
am pretty sure the bug applies to both directions.
