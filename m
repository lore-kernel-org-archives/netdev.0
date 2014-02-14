From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nft_meta: fix typo "CONFIG_NET_CLS_ROUTE"
Date: Fri, 14 Feb 2014 18:00:32 +0100
Message-ID: <20140214170031.GB7415@localhost>
References: <1392198781.23759.15.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Richard Weinberger <richard@nod.at>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392198781.23759.15.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 10:53:01AM +0100, Paul Bolle wrote:
> There are two checks for CONFIG_NET_CLS_ROUTE, but the corresponding
> Kconfig symbol was dropped in v2.6.39. Since the code guards access to
> dst_entry.tclassid it seems CONFIG_IP_ROUTE_CLASSID should be used
> instead.

Applied, thanks.
