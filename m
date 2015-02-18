From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: xt_socket: fix a stack corruption bug
Date: Thu, 19 Feb 2015 00:45:42 +0100
Message-ID: <20150218234542.GA21773@salvia>
References: <1424055825.4942.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Balazs Scheidler <bazsi@balabit.hu>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424055825.4942.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 15, 2015 at 07:03:45PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> As soon as extract_icmp6_fields() returns, its local storage (automatic
> variables) is deallocated and can be overwritten.
> 
> Lets add an additional parameter to make sure storage is valid long
> enough.
> 
> While we are at it, adds some const qualifiers.

Applied, thanks Eric.
