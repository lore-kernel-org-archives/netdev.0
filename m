From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPX]: Fix checksum computation.
Date: Fri, 31 Oct 2003 16:25:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031162516.0b2bd38d.davem@redhat.com>
References: <200310312006.h9VK62Hh005910@hera.kernel.org>
	<1067635446.11564.92.camel@localhost.localdomain>
	<20031031132331.35a9aaca.davem@redhat.com>
	<1067637004.11564.98.camel@localhost.localdomain>
	<20031031135328.2a997f6a.davem@redhat.com>
	<20031031142131.07176dd7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031031142131.07176dd7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 31 Oct 2003 14:21:31 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Actually, the before the "optimization" went in I did testing between
> old 2.4.x and 2.6.x as well as standalone comparisons.  The problem is
> a compiler screwup, that probably isn't worth investigating further.

See Mark Huth's email, I think his analysis is correct and
that the two pieces of C code are really doing different
things.
