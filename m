From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Thu, 5 May 2005 16:16:10 -0700
Message-ID: <20050505161610.16e3ccdc.davem@davemloft.net>
References: <20050504230731.12be1bc3.davem@davemloft.net>
	<20050505153532.30159bd5.davem@davemloft.net>
	<20050505162448.3278aa8f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050505162448.3278aa8f@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 May 2005 16:24:48 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> On Thu, 5 May 2005 15:35:32 -0700
> "David S. Miller" <davem@davemloft.net> wrote:
> 
> > 
> > Is anyone testing this or is everyone too scared? :-)
> > 
> > A lot of people wanted this TSO stuff fixed, so I spent
> > time implementing the fix.  Yet nobody seems interested
> > enough to even say "it works" or "it's busted" :-/
> 
> It works on tg3 that is too stupid to do TSO at least. More tests coming

It's off by default, "ethtool -K eth0 tso on" is necessary.
I'll change that soon.

Or do you have a chip revision that really can't do TSO?
