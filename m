From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] net: netfilter: Fix undefined reference to
 nf_nat_redirect_* functions
Date: Wed, 26 Nov 2014 12:33:48 +0100
Message-ID: <20141126113348.GC24801@breakpoint.cc>
References: <1416928034-10882-1-git-send-email-rupran@einserver.de>
 <1416994537-1592-1-git-send-email-rupran@einserver.de>
 <20141126102402.GA24801@breakpoint.cc>
 <5475AC6F.9010902@einserver.de>
 <20141126112449.GA4700@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Ruprecht <rupran@einserver.de>,
	Florian Westphal <fw@strlen.de>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141126112449.GA4700@salvia>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> 2) Merge nf_nat_redirect_ipv4 and nf_nat_redirect_ipv6 into
> nf_nat_redirect, so we inconditionally build IPv6 redirect code, thus
> xt_REDIRECT always finds the IPv6 symbol that needs even if it doesn't
> use it.

Seems this is the best solution since it would also reduce the
kconfig option symbol count.

afaics there is nothing ipv6 specific in nf_nat_redirect_ipv6 so
this should not cause any of the ususal IPV6=m dependency issues.
