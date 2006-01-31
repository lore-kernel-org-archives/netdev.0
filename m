From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge bridge & hw csum failure (Was: Re: [BUG] sky2 broken for
 Yukon PCI-E Gigabit Ethernet Controller 11ab:4362 (rev 19))
Date: Mon, 30 Jan 2006 16:15:51 -0800
Message-ID: <20060130161551.623a3ad0@dxpl.pdx.osdl.net>
References: <20060130231658.GA6952@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Knut Petersen <Knut_Petersen@t-online.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030238AbWAaAQW@vger.kernel.org>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20060130231658.GA6952@ee.oulu.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Jan 2006 01:16:59 +0200
Pekka Pietikainen <pp@ee.oulu.fi> wrote:

> On Fri, Jan 27, 2006 at 11:22:42PM +1100, Herbert Xu wrote:
> > OK, although we can't rule out sky2/netfilter from the enquiry, I've
> > identified two bugs in ppp/pppoe that may be responsible for what you
> > are seeing.  So please try the following patch and let us know if the
> > problem still exists (or deteriorates/improves).
> Borrowing this thread for a related problem, I'm getting lots of those on a
> bridge device (this one running skge, rmmod skge; modprobe sk98lin actually
> seemed to do it too, I've disabled rx checksums with ethtool for now). 
> Kernel is a 2.6.15.1-ish Fedora one.

Okay, what is the hardware version:
	dmesg | grep skge
Maybe that chip rev is no good.
