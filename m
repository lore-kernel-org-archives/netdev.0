From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 09 Mar 2005 14:50:14 +1100
Message-ID: <1110340214.32524.32.camel@gaston>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	 <1110334456.32556.21.camel@gaston>
	 <20050308194229.41c23707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@oss.sgi.com, linuxppc-embedded@ozlabs.org
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050308194229.41c23707.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-08 at 19:42 -0800, David S. Miller wrote:
> On Wed, 09 Mar 2005 13:14:16 +1100
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
> > I'll have a closer look when I find some time, see if it makes sense to
> > adapt sungem or not.
> 
> Especially because of the Broadcom PHYs I bet it doesn't.
> 
> Too many chips have to reset the MAC, or do other fancy stuff
> when programming the PHY to make this genphy thing very useful.

Oh, I think genphy is just a generic driver, but his layer has hooks for
other PHY drivers (wasn't it based on sungem_phy in the first place ?)

I discussed several steps of the design with Andy, the idea was to have
something a bit like sungem_phy.c with addditional common library for
doing the link polling & fallback stuff etc... that could be easily
shared by drivers.

Ben.
