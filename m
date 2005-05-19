From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.12-rc4-mm[12] - ULOG problem
Date: Thu, 19 May 2005 11:44:25 -0700 (PDT)
Message-ID: <20050519.114425.18307286.davem@davemloft.net>
References: <20050518222729.007887b8.akpm@osdl.org>
	<1116484313.21310.78.camel@uganda>
	<20050518234552.4aef6d02.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <20050518234552.4aef6d02.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Wed, 18 May 2005 23:45:52 -0700

> > Should I ask David Miller to allocate new one specially for connector?
> 
> Dave?

Giving the connector a single value 10 is OK, the rest of
what the connector is doing in this area is not.

I wish you hadn't put the connector into -mm, it's really
in need of several fixups still.  The bogus reuse of the
ULOG netlink number is simply indicative of that.
