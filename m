From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Fri, 11 Mar 2005 10:27:47 +1100
Message-ID: <1110497267.32524.295.camel@gaston>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com>
	 <1110334456.32556.21.camel@gaston>
	 <20050308194229.41c23707.davem@davemloft.net>
	 <1110340214.32524.32.camel@gaston>
	 <57a429f8eb807987d88b06129861d507@freescale.com>
	 <4230D1AC.5070506@katalix.com> <1110495992.32525.290.camel@gaston>
	 <4230D7F4.8060900@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: James Chapman <jchapman@katalix.com>,
        Andy Fleming <afleming@freescale.com>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>, linuxppc-embedded@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4230D7F4.8060900@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-03-10 at 18:27 -0500, Jeff Garzik wrote:

> I haven't had time to review the phy abstraction layer, but my gut 
> feeling is that there are several common code patterns which could be 
> abstracted out, to save code.
> 
> Typically there will be one or more phy-specific functions in each 
> 10/100 or GigE driver, falling back to a default 'genphy' driver when 
> things are completely MII/GMII-compatible.

Exactly. One thing for which i usually need PHY specific functions
(pretty much all the time) is PHY init (thanks Broadcom) and suspend.

Ben.
