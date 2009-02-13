From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Fri, 13 Feb 2009 16:12:56 +0300
Message-ID: <20090213131256.GE23879@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090213125215.GC23879@ioremap.net> <alpine.LSU.2.00.0902131402460.9310@fbirervta.pbzchgretzou.qr>
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
In-Reply-To: <alpine.LSU.2.00.0902131402460.9310@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2009 at 02:03:10PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >> >	printf("OS fingerprint match options:\n"
> >> >		"--genre [!] string	Match a OS genre by passive fingerprinting.\n"
> >> 
> >> The syntax should be  [!] --genre string, that is what most
> >> others use. Then the check_inverse call also be removed.
> >
> >Actually not, it has genre not Linux (Windows, Solaris, HPUX and so on).
> 
> It may not coincide with English grammar, but it is easier to parse.

'! --genre Linux' means this option was not specified,
'--genre ! Linux' means everything but Linux.

-- 
	Evgeniy Polyakov
