From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Fri, 11 Mar 2005 10:06:32 +1100
Message-ID: <1110495992.32525.290.camel@gaston>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	 <1110334456.32556.21.camel@gaston>
	 <20050308194229.41c23707.davem@davemloft.net>
	 <1110340214.32524.32.camel@gaston>
	 <57a429f8eb807987d88b06129861d507@freescale.com>
	 <4230D1AC.5070506@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linuxppc-embedded@ozlabs.org
To: James Chapman <jchapman@katalix.com>
In-Reply-To: <4230D1AC.5070506@katalix.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-10 at 23:01 +0000, James Chapman wrote:
> Hi Andy,
> 
> Can you elaborate on why this phy abstraction is needed?
> 
> In your original post, you mentioned that you were going to post a
> patch to show how your code would be hooked up in an existing net
> driver. Did I miss it? It would help in understanding the pros and cons
> of using genphy over using plain old mii.c.
> 
> btw, I recently posted a patch to add GigE support to mii.c which is
> in Jeff's netdev-2.6 queue. Some register definitions were added in
> mii.h that will collide with yours.

A variety of PHY chips require special cases that aren't handled by the
generic mii code. The PHY driver layer allows to plug PHY specific
drivers, with genphy just being the "default" for sane chips.

Also, I think Andy added more to the PHY layer than what mii does, like
support for the interrupt or timer based link management etc... which
tend to be the same in a lot of drivers.

Ben.
