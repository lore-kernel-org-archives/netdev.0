From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Fri, 19 Dec 2003 15:32:42 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031219153242.B1390@sygehus.dk>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com> <20031209223214.A1855@sygehus.dk> <3FD64EC9.6010203@candelatech.com> <20031209224906.M53356@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <20031209224906.M53356@sygehus.dk>; from rask@sygehus.dk on Wed, Dec 10, 2003 at 12:40:02AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 10, 2003 at 12:40:02AM +0100, Rask Ingemann Lambertsen wrote:

> That said, even checking CONFIG_VLAN_8021Q is probably flawed too, because 
> ideally, even when building a kernel without VLAN support, you should be able 
> to use the bridging support in a VLAN environment. IMHO. I mean, if this is 
> not the case, please remind me why we need VLAN patches in the first place 
> since setting an MTU of 1496 bytes works with every Ethernet board and driver.

Further, why is it not the responsibility of vconfig to ensure that the MTU
of the VLAN device is 4 lower than that of the underlying, "bare" Ethernet
device?

-- 
Regards,
Rask Ingemann Lambertsen
