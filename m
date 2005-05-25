From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] dummy: improve performance
Date: Wed, 25 May 2005 15:11:49 -0700 (PDT)
Message-ID: <20050525.151149.08323692.davem@davemloft.net>
References: <Pine.LNX.4.62.0505201306110.29305@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: util@deuroconsult.ro
In-Reply-To: <Pine.LNX.4.62.0505201306110.29305@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Date: Fri, 20 May 2005 13:11:24 +0300 (EEST)

> I tested the speed and seems very low (both old version and the new one).
> Something like 37Mbits/s. It is normal?
> I can easily get 80Mbit/s on the same machine on ethernet.

How are you receiving packets on the dummy device for
performance testing?  This device is a transmit blackhole
and receives no packets :-)

I really don't see a real need for your patch, dummy device
performance cannot be claimed to be important at all.
