From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Sun, 19 Dec 2004 19:15:35 -0500
Message-ID: <41C619A7.1060302@pobox.com>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>	 <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net> <1103497516.1046.231.camel@jzny.localdomain> <41C612BC.5070909@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com,
        Paul Jakma <paul@clubi.ie>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41C612BC.5070909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tommy Christensen wrote:
> It was at least to the same effect. The key issue is whether the
> packets are kept in the queue (qdisc) until the link is back up,
> or they are drained (and dropped) by the driver.


They should absolutely not be dropped by the driver.  No ifs, ands, or buts.

This sort of problem is NOT solved by modifying hundreds of drivers.

	Jeff
