From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match (iptables part)
Date: Sun, 15 Feb 2009 20:35:03 +0300
Message-ID: <20090215173502.GB19556@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121922280.20367@fbirervta.pbzchgretzou.qr> <20090213125215.GC23879@ioremap.net> <alpine.LSU.2.00.0902131402460.9310@fbirervta.pbzchgretzou.qr> <20090213131256.GE23879@ioremap.net> <alpine.LSU.2.00.0902131452010.9310@fbirervta.pbzchgretzou.qr>
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
In-Reply-To: <alpine.LSU.2.00.0902131452010.9310@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 13, 2009 at 02:54:25PM +0100, Jan Engelhardt (jengelh@medozas.de) wrote:
> >'! --genre Linux' means this option was not specified,
> >'--genre ! Linux' means everything but Linux.
> 
> Well not in iptables. Not specifying an option is represented by 
> voidness/absence of any string. (E.g. iptables -d 192.168.0.0/16  vs.
> iptables ! -s 172.16.0.0/12 -d 192.168.0.0/16)
> Also, (!(--genre == "linux")) is eqv. (--genre != "linux")
> is equivalent in boolean logic  ;-)

And that's not what should be :)
In the code it is intended to be:
(--genre && (--genre != Linux))

But I really do not care where to put a '!' sign in the documentation
string :)

-- 
	Evgeniy Polyakov
