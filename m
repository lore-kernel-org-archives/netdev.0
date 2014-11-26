From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2] net: netfilter: Fix undefined reference to
 nf_nat_redirect_* functions
Date: Wed, 26 Nov 2014 11:24:02 +0100
Message-ID: <20141126102402.GA24801@breakpoint.cc>
References: <1416928034-10882-1-git-send-email-rupran@einserver.de>
 <1416994537-1592-1-git-send-email-rupran@einserver.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andreas Ruprecht <rupran@einserver.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416994537-1592-1-git-send-email-rupran@einserver.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Ruprecht <rupran@einserver.de> wrote:
> Additionally it is necessary to provide stubs for the
> nf_nat_redirect_ipv{4,6} functions in case the header is included but
> the corresponding Kconfig feature is not enabled.

Hmmm, not following.

Can you elaborate?

Under which circumstances do we have a call to nf_nat_redirect_ipv4()
(i.e., linker error) but can safely do a noop operation instead of the
requested nat redirect...?
