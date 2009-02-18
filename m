From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 16:02:32 +0100
Message-ID: <499C2308.2000109@trash.net>
References: <20090212171245.GA15025@ioremap.net> <alpine.LSU.2.00.0902121900520.20367@fbirervta.pbzchgretzou.qr> <20090212185729.GA17896@ioremap.net> <alpine.LSU.2.00.0902122045080.670@fbirervta.pbzchgretzou.qr> <20090213130347.GD23879@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090213130347.GD23879@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> But I placed OSF into net/ipv4/netfilter/ipt_osf.c, should it be moved
> into different location?

Not necessarily as long as it only supports IPv4, but it would be
good to have the API flexible enough from the start to also support
IPv6. But I don't see a problem with this in the current patchset.


