From: Christoph Hellwig <hch@lst.de>
Subject: Re: [patch - Nicholas's tree] netconsole: Missing unlock on error
	path
Date: Sun, 4 Oct 2015 08:36:13 +0200
Message-ID: <20151004063613.GB13199@lst.de>
References: <20151003190524.GA766@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151003190524.GA766@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 03, 2015 at 10:05:24PM +0300, Dan Carpenter wrote:
> We added new locking to this function but we missed one error path which
> needs an unlock.
> 
> Fixes: cdacad4993f4 ('netconsole: use per-attribute show and store methods')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> This is going through Nicholas Bellinger's tree not net-next.

Hi Dan,

this was fixed a while ago, I'm actually surpised it was still in the patches
Nic merged.  My repost from earlier yesterday should have fixed it.
