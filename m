From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Sun, 15 Feb 2009 20:32:35 +0300
Message-ID: <20090215173234.GA19556@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net> <alpine.LSU.2.00.0902131448040.9310@fbirervta.pbzchgretzou.qr> <20090213142204.GA27554@ioremap.net> <alpine.LSU.2.00.0902131541200.17695@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0902131541200.17695@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2009 at 03:41:36PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> But still it has to jump over anything it does not check.

Yes, that may be unaligned. I think instead of get_unaligned() it will
be faster to access it as two chars instead.

-- 
	Evgeniy Polyakov
