From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: register pernet subsystem before register L4
 proto
Date: Fri, 15 Mar 2013 12:55:38 +0100
Message-ID: <20130315115538.GA9608@localhost>
References: <1362712846-12954-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	ebiederm@xmission.com, Alexey Dobriyan <adobriyan@gmail.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1362712846-12954-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 08, 2013 at 11:20:46AM +0800, Gao feng wrote:
> In commit c296bb4d5d417d466c9bcc8afef68a3db5449a64
> "netfilter: nf_conntrack: refactor l4proto support for netns",
> we register l4proto gre/dccp/udplite/sctp before register
> pernet subsystem,it's a wrong order.
> 
> We should register pernet subsystem before register L4proto,
> since after register L4proto, init_conntrack may try to access
> the resources which allocated in register_pernet_subsys.

Applied to nf tree, thanks.
