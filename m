From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: [PATCH] natsemi update 4/4 External Fibre phy
Date: Sun, 06 Jun 2004 18:01:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40C33FC5.2070604@colorfullife.com>
References: <200406041456330453.0BC6681C@136.179.85.112>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gary N Spiess <Gary.Spiess@Intermec.com>
In-Reply-To: <200406041456330453.0BC6681C@136.179.85.112>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gary N Spiess wrote:

>
> +/* add a couple of MII definitions specific to a PORT_FIBRE 
> implementation */
> +#define MII_MCTRL      0x15    /* mode control register */
> +#define MII_IN_FX_MODE 0x0001  /* full duplex */
> +#define MII_DIS_SCRM   0x0004  /* disable scrambler */
>  

Specific to a PORT_FIBRE implementation or specific to the PHY you are 
using? I think register 0x15 is implementation specific.

Why do you actually want to handle the fibre phy as a new port? I'd 
handle phy specific code by reading the MII_PHYSID{1,2} register and 
then adding a special case if your phy is detected. The port can remain 
at PORT_MII.

--
    Manfred
