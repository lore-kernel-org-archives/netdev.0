From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 2/3] netfilter: potential null derefence.
Date: Thu, 1 Mar 2012 13:30:04 +0100
Message-ID: <20120301123004.GA7250@1984>
References: <1330593434-19275-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1330593434-19275-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 01, 2012 at 02:47:14PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> I am getting following error.
> " net/bridge/netfilter/ebtables.c:269 ebt_do_table()
>   error: potential null derefence 'cs'"
> 
>     i = cs[sp].n;  // If cs == Null then this will cause problem.

Very sorry, I didn't see the out label.

I'll apply this to my nf [1] once David takes my previous request for
pulling.

[1] http://1984.lsi.us.es/git/net
