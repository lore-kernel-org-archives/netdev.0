From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 0/9]: TCP: The Road to Super TSO
Date: Mon, 06 Jun 2005 22:51:33 -0700 (PDT)
Message-ID: <20050606.225133.74747961.davem@davemloft.net>
References: <20050606.210846.07641049.davem@davemloft.net>
	<42A528F0.2090208@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au, jheffner@psc.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <42A528F0.2090208@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Mon, 06 Jun 2005 21:56:16 -0700

> I'll merge these with the TCP infrastructure stuff and
> send it off to Andrew. Actually, it is more of fix the TCP
> infrastructure to match TSO + rc6 but you get the ida.

Probably not a good idea, it's %75 of the implementation
of Super TSO and totally conflicts with the super TSO patch.

Probably best to keep the existing Super TSO stuff in there
until I'm done with this stuff. :)
