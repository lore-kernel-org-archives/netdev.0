From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Wed, 22 Dec 2004 06:07:52 -0500
Message-ID: <20041222110752.GA11969@havoc.gtf.org>
References: <41C71FFD.7090308@pobox.com> <OFD729E7DA.203E1D4A-ONC1256F72.003B7A8E-C1256F72.003C1150@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>,
        Tommy Christensen <tommy.christensen@tpack.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Spatzier <thomas.spatzier@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFD729E7DA.203E1D4A-ONC1256F72.003B7A8E-C1256F72.003C1150@de.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2004 at 11:56:06AM +0100, Thomas Spatzier wrote:
> on cable reconnected:
>       netif_carrier_on();
>       netif_wake_queue();

Side note to all driver authors, make sure you only ever start or
wake the queue if there is truly space available for another skb.

	Jeff
