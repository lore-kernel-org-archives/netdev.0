From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [resend] Passive OS fingerprint xtables match.
Date: Fri, 29 May 2009 14:20:23 +0400
Message-ID: <20090529102023.GA17591@ioremap.net>
References: <20090511095343.GA30778@ioremap.net> <4A1D6A20.8050404@trash.net> <20090529085918.GA11887@ioremap.net> <alpine.LSU.2.00.0905291144460.9095@fbirervta.pbzchgretzou.qr>
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
In-Reply-To: <alpine.LSU.2.00.0905291144460.9095@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan.

On Fri, May 29, 2009 at 11:49:51AM +0200, Jan Engelhardt (jengelh@medozas.de) wrote:
> >> >+config NETFILTER_XT_MATCH_OSF
> >> >+	tristate '"osf" Passive OS fingerprint match'
> >> >+	depends on NETFILTER_ADVANCED
> >> 
> >> && NFNETLINK
> >
> >Will add.
> 
> Does it really need to depend on nfnetlink? Even if I just want to
> have it dumped to syslog?

OSF is configured by nfnetlink now.

-- 
	Evgeniy Polyakov
