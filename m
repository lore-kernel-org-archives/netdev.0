From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Compat32 setsockopt overzealous conversions
Date: Fri, 10 Sep 2004 16:43:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910164354.3cdffa59.davem@davemloft.net>
References: <1094563381.5122.8.camel@localhost.localdomain>
	<20040907140649.42eaa278.davem@davemloft.net>
	<1094716398.15909.27.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1094716398.15909.27.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 09 Sep 2004 08:53:18 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

2.4.x patch applied, thanks David.

> Back in the real world of 2.6, we REALLY do need to stop trying to do
> all this in a sockopt syscall wrapper, and instead pass down a 32/64 bit
> flag to the code which actually handles the sockopt -- although the
> optlen ought to be sufficient for the _majority_ of cases. Or maybe we
> should handle it like we do ioctls? 

That latter idea (doing it like ioctls) is an option, and in
fact I like it since it would allow us to push the complicated
netfilter translators into the netfilter code.
