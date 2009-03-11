From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 11 Mar 2009 10:54:21 +0100
Message-ID: <49B78A4D.4060703@netfilter.org>
References: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090310151357.GA10658@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Hi.
> 
> Passive OS fingerprinting netfilter module allows to passively detect
> remote OS and perform various netfilter actions based on that knowledge.
> This module compares some data (WS, MSS, options and it's order, ttl, df
> and others) from packets with SYN bit set with dynamically loaded OS
> fingerprints.
> 
> Fingerprint matching rules can be downloaded from OpenBSD source tree
> and loaded via netlink connector into the kernel via special util found
> in archive. It will also listen for events about matching packets.

I like this feature. We have nfnetlink so I don't see why we should use
the netlink connector instead.

BTW, is there any difference with regards to userspace p0f apart from
having this integrated into iptables?

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
