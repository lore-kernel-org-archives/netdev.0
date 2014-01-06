From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: release conntrack from rcu
  callback
Date: Mon, 6 Jan 2014 22:09:33 +0400
Message-ID: <20140106180933.GB2360@moon>
References: <1389023672-14351-1-git-send-email-avagin@openvz.org>
 <20140106170235.GJ28854@breakpoint.cc>
 <20140106172130.GA2360@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Vagin <avagin@openvz.org>, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	vvs@openvz.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106172130.GA2360@moon>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 06, 2014 at 09:21:30PM +0400, Cyrill Gorcunov wrote:
> 
> No? Or there something obvious I'm missing?

Drop my assumption, it can't happen (iow either dying bit is set,
either it clean but tuple can't match then).
