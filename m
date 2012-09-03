From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] netfilter: pass 'nf_hook_ops' instead of
 'list_head' to nf_iterate()
Date: Mon, 3 Sep 2012 17:31:42 +0200
Message-ID: <20120903153142.GB19926@1984>
References: <5035C6DD.3000600@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	coreteam@netfilter.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>, kaber@trash.net
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5035C6DD.3000600@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 23, 2012 at 01:59:57PM +0800, Michael Wang wrote:
> From: Michael Wang <wangyun@linux.vnet.ibm.com>
> 
> Since 'list_for_each_continue_rcu' has already been replaced by
> 'list_for_each_entry_continue_rcu', pass 'list_head' to nf_iterate() as a
> parameter can not benefit us any more.
> 
> This patch will replace 'list_head' with 'nf_hook_ops' as the parameter of
> nf_iterate() to save code.

Applied, thanks.
