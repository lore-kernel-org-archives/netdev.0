From: "David S. Miller" <davem@davemloft.net>
Subject: Re: via-rhine unable to send back-to-back packets?
Date: Tue, 30 Nov 2004 12:25:03 -0800
Message-ID: <20041130122503.0adac947.davem@davemloft.net>
References: <20041129222700.GA22918@xi.wantstofly.org>
	<20041129172540.6b959858.davem@davemloft.net>
	<20041130064823.GA27872@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041130064823.GA27872@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 30 Nov 2004 07:48:23 +0100
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> Yeah, preamble (8 bytes), CRC (4 bytes), inter-packet gap (12 bytes).

Ok.

> Perhaps the via-rhine simply can't send out packets back-to-back and
> needs 14 byte times of inter-packet gap.  I couldn't find any stray +2
> in the driver anywhere but I'm just checking.

Or the via-rhine driver is not programming one of the registers
proper to get optimal spacing.

As with most Donald Becker drivers, many of the register layouts
are not documented in the sources so it's not possible to just
scan the driver looking for potential problems like this.
For example, maybe the TxConfig register has an "IPG" field but
we'll never know by reading anything in the driver source.
