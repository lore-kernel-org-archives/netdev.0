From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [AX25, ROSE] Remove useless SET_MODULE_OWNER calls.
Date: Sun, 30 Apr 2006 23:38:02 +1000
Message-ID: <E1FaC7e-0003Cj-00@gondolin.me.apana.org.au>
References: <1146398606.2252.1.camel@localhost.localdomain>
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58120 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751076AbWD3NiQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 09:38:16 -0400
To: dcbw@redhat.com (Dan Williams)
In-Reply-To: <1146398606.2252.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw@redhat.com> wrote:
> 
> Are these done by anything else now?  Did something change to make
> SET_MODULE_OWNER useless in individual drivers?  I'm asking because I

SET_MODULE_OWNER has been a no-op ever since Dave made live network
device driver modules unloadable nearly three years ago.

> was fairly sure that SET_MODULE_OWNER set up some sysfs links and such
> that HAL depends on to figure out information about the driver and
> hardware device, much like SET_NETDEV_DEV.

For PCI drivers the module information is injected by pci_register_driver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
