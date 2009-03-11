From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 11 Mar 2009 13:00:38 +0300
Message-ID: <20090311100038.GA9560@ioremap.net>
References: <20090310151357.GA10658@ioremap.net> <49B78A4D.4060703@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49B78A4D.4060703@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Pablo.

On Wed, Mar 11, 2009 at 10:54:21AM +0100, Pablo Neira Ayuso (pablo@netfilter.org) wrote:
> > Fingerprint matching rules can be downloaded from OpenBSD source tree
> > and loaded via netlink connector into the kernel via special util found
> > in archive. It will also listen for events about matching packets.
> 
> I like this feature. We have nfnetlink so I don't see why we should use
> the netlink connector instead.

OSF exists about 6 years already, netlink configuration was added in
2005, I do not remember if nfnetlink existed those days (IIRC it did
not, since I reused ULOG netlink first), right now I just cleanup
what was written before.

> BTW, is there any difference with regards to userspace p0f apart from
> having this integrated into iptables?

There should be no major differences, there are some tweaks for the
MTU comparison, maybe something else.

-- 
	Evgeniy Polyakov
