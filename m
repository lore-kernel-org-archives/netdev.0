From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:42:41 -0700 (PDT)
Message-ID: <20050519.114241.59656850.davem@davemloft.net>
References: <1116484313.21310.78.camel@uganda>
	<20050518234552.4aef6d02.akpm@osdl.org>
	<1116486385.21310.82.camel@uganda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <1116486385.21310.82.camel@uganda>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 19 May 2005 11:06:25 +0400

> It was created to be able to load several different connector devices 
> from different modules [basically it was module1.ko unit=10, module2.ko
> unit=11 and so on].

That's bogus, each connector will need to allocate it's own
specific define in the netlink header, and we're about to
run out of numbers.

Please redesign the connector so that it doesn't eat more than
one netlink number, we're running out of them soon.
