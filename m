From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Tue, 30 Nov 2004 23:06:44 +0100
Message-ID: <20041130220644.GC29947@k3.hellgate.ch>
References: <20041129222700.GA22918@xi.wantstofly.org> <20041129172540.6b959858.davem@davemloft.net> <20041130064823.GA27872@xi.wantstofly.org> <20041130122503.0adac947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041130122503.0adac947.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004 12:25:03 -0800, David S. Miller wrote:
> Lennert Buytenhek <buytenh@wantstofly.org> wrote:
> > Perhaps the via-rhine simply can't send out packets back-to-back and
> > needs 14 byte times of inter-packet gap.  I couldn't find any stray +2
> > in the driver anywhere but I'm just checking.
> 
> Or the via-rhine driver is not programming one of the registers
> proper to get optimal spacing.
> 
> As with most Donald Becker drivers, many of the register layouts
> are not documented in the sources so it's not possible to just
> scan the driver looking for potential problems like this.
> For example, maybe the TxConfig register has an "IPG" field but
> we'll never know by reading anything in the driver source.

Presumably Donald Becker had only access to the publicly available
documentation at the time which is very incomplete and buggy. What
little time my day job leaves for hacking via-rhine is consumed by the
WOL issues that have come up with 2.6.9+, but if you have a specific
question that can be answered by someone who knows the chip but not
necessarily Linux I can try and poke my contacts.

Of course, you can always check if VIA's driver has the same issue. If
it doesn't, chances are we can borrow the fix.

Roger
