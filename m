From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] Check net->nfnl for NULL in ctnetlink_conntrack_event
 to, avoid Oops on container destroy
Date: Wed, 14 Sep 2011 14:31:38 +0200
Message-ID: <20110914123138.GA19715@1984>
References: <4E6E4961.9070802@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Tim Gardner <tim.gardner@canonical.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4E6E4961.9070802@canonical.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2011 at 12:03:13PM -0600, Tim Gardner wrote:
> Patrick,
> 
> I received this patch from a developer that uses lxc and network
> name spaces. I don't know the locking semantics well enough for CT
> to judge whether this fix is sufficient. Bug info can be found at
> http://bugs.launchpad.net/bugs/843892 . See comment #7 for his
> analysis.

We're still discussing a better solution for it.
