From: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 3 Jan 2005 10:10:56 +0100
Message-ID: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
References: <1103723307.1092.83.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1103723307.1092.83.camel@jzny.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





jamal <hadi@cyberus.ca> wrote on 22.12.2004 14:48:28:
> I think this needs to be resolved too.
> It is possible to have a centralized action instead of requiring drivers
> to make changes if we know the state of the driver is in netcarrier_off.
> What that would require is
> on cable gone, you just say:
>       netif_carrier_off();
> and the top layer code will junk the packets before they hit the driver.
> This way the socket code can continue sending whatever it wants but if
> theres no link, then its fair to drop those packets?
>
> If this acceptable i can generate a quick patch.

Does Jamal's solution sound good for all? Then I would change my driver
to do the following:
just call netif_carrier_off() (not netif_stop_queue)

Then the upper layers will do the propper thing, so I should not
get any more packets. If I still get some, I will drop them.
Did I get this correctly?

BTW: A happy new year to all ;-)

Regards,
Thomas.
