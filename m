From: jamal <hadi@cyberus.ca>
Subject: Re: [patch 4/10] s390: network driver.
Date: 06 Jan 2005 08:58:32 -0500
Message-ID: <1105019912.2314.20.camel@jzny.localdomain>
References: <OFB7F7E23F.EFB88418-ONC1256F7E.0031769E-C1256F7E.003270AD@de.ibm.com>
	 <1104764710.1048.580.camel@jzny.localdomain>  <41DB26A6.2070008@pobox.com>
	 <1104895169.1117.63.camel@jzny.localdomain>  <41DC0931.80603@tpack.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41DC0931.80603@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-01-05 at 10:35, Tommy Christensen wrote:
> jamal wrote:

> 
> Except for the drivers that call netif_stop_queue() on link-down. These
> calls (and the corresponding netif_wake_queue) would have to be removed.

If we assume all drivers do:
netif_stop then carrier_off then you dont need that extra check.
Thats the working assumption i had - maybe a comment is deserving or
we could say we dont think that all drivers are going to follow that 
sequence.

cheers,
jamal
