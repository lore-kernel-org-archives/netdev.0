From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 20 Dec 2004 13:56:32 -0500
Message-ID: <41C72060.1010400@pobox.com>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>  <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net> <1103497516.1046.231.camel@jzny.localdomain> <41C612BC.5070909@tpack.net> <Pine.LNX.4.61.0412201413240.5211@sheen.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tommy Christensen <tommy.christensen@tpack.net>,
        Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Jakma <paul@clubi.ie>, hadi@cyberus.ca
In-Reply-To: <Pine.LNX.4.61.0412201413240.5211@sheen.jakma.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Paul Jakma wrote:
>>   responsibility of the application to flush the socket on
>>   link-down events (by down'ing the interface?).
> 
> 
> That seems more complex than needs be, for userspace at least.

It is the responsibility of the kernel to push complexity to userland.

Some applications may NOT desire that the socket be flushed.  That's an 
app policy decision.

If this is the core issue, then I am even more inclined to think that 
the kernel is not what needs to be modified here.

	Jeff
