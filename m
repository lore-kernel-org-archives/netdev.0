From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: xt_LOG: fix mark logging for IPv6 packets
Date: Wed, 29 May 2013 13:18:22 +0200
Message-ID: <20130529111822.GA5162@localhost>
References: <20130529084118.6676862C72@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, coreteam@netfilter.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130529084118.6676862C72@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 29, 2013 at 10:37:03AM +0200, Michal Kubecek wrote:
> In dump_ipv6_packet(), the "recurse" parameter is zero only if
> dumping contents of a packet embedded into an ICMPv6 error
> message. Therefore we want to log packet mark if recurse is
> non-zero, not when it is zero.

Applied, thanks Michal.

The problem seems to be there since the beginning, ie. 2.6.26.
