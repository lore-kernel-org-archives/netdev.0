From: Paul Jakma <paul@clubi.ie>
Subject: Re: [patch 4/10] s390: network driver.
Date: Mon, 20 Dec 2004 14:16:47 +0000 (UTC)
Message-ID: <Pine.LNX.4.61.0412201413240.5211@sheen.jakma.org>
References: <OF28701C56.81E1D26E-ONC1256F6B.00513EDD-C1256F6B.0052AF84@de.ibm.com>
  <1103484552.1046.155.camel@jzny.localdomain>  <41C600D7.70005@tpack.net>
 <1103497516.1046.231.camel@jzny.localdomain> <41C612BC.5070909@tpack.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: hadi@cyberus.ca, Thomas Spatzier <thomas.spatzier@de.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Hasso Tepper <hasso@estpak.ee>,
        Herbert Xu <herbert@gondor.apana.org.au>, jgarzik@pobox.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <41C612BC.5070909@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Dec 2004, Tommy Christensen wrote:

>> For a routing protocol that actually is notified that the link 
>> went down, it should probably flush those socket buffer at that 
>> point.

Or why not return an error, as soon as possible on the socket, eg 
ENOBUFS, and discard anything in the queue before that. Make it 
configurable via a sockopt if you think it'd harm ordinary apps 
(though, anything that cant deal with ENOBUFS is broken already, 
really..) or make it apply only to nonblock sockets.

>   responsibility of the application to flush the socket on
>   link-down events (by down'ing the interface?).

That seems more complex than needs be, for userspace at least.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
Fortune:
"Paul Lynde to block..."
-- a contestant on "Hollywood Squares"
