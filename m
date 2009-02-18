From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 18:07:42 +0300
Message-ID: <20090218150742.GA30490@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net> <499C2308.2000109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499C2308.2000109@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 18, 2009 at 04:02:32PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> >But I placed OSF into net/ipv4/netfilter/ipt_osf.c, should it be moved
> >into different location?
> 
> Not necessarily as long as it only supports IPv4, but it would be
> good to have the API flexible enough from the start to also support
> IPv6. But I don't see a problem with this in the current patchset.

I've already moved it in the my testing tree as long as incorporate all
other changes, I will run it for some time and resubmit tomorrow or so
:)

As of IPv6 support - it could be fairly trivial, the only thing we need
is to dereference TCP header with the appropriate offset anf get don't
fragment bit (ipv6 does not have it, so we could check both entries).

But... I do not have IPv6 network to test the changes (and definitely
did not have it 6 years ago), so it was never implemented :)

-- 
	Evgeniy Polyakov
