From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter 15/29: nf_conntrack: connection tracking helper name
 persistent aliases
Date: Thu, 27 Nov 2008 19:31:31 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0811271930061.21626@fbirervta.pbzchgretzou.qr>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet> <20081127161523.13891.6192.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161523.13891.6192.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2008-11-27 17:15, Patrick McHardy wrote:
>    
>    This patch adds the macro MODULE_ALIAS_NFCT_HELPER that defines a
>    way to provide generic and persistent aliases for the connection
>    tracking helpers.

I wonder a bit. iptables is fine with loading ipt_%s (mapped to xt_%s),
but conntrack requires an nfct-help-%s namespace and cannot use
nf_conntrack_%s?
Of course it makes sense to use a separate namespace - especially
in light of the nf_conntrack_ prefix used by both helpers and
protos, but I'm still asking.
