From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 17/17] rds: switch rds_message_copy_from_user() to
 iov_iter
Date: Mon, 24 Nov 2014 10:17:50 +0000
Message-ID: <20141124101750.GF7996@ZenIV.linux.org.uk>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
 <20141120214753.GR7996@ZenIV.linux.org.uk>
 <20141120.182339.972861702759954603.davem@davemloft.net>
 <20141121.122615.1091044030302005883.davem@davemloft.net>
 <20141122042856.GZ7996@ZenIV.linux.org.uk>
 <20141122043920.GQ30478@ZenIV.linux.org.uk>
 <1416794418.7215.74.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel@vger.kernel.org, nab@linux-iscsi.org,
	hch@infradead.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416794418.7215.74.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 24, 2014 at 02:00:18AM +0000, Ben Hutchings wrote:
> On Sat, 2014-11-22 at 04:39 +0000, Al Viro wrote:
> [...]
> > -		ret = rds_page_copy_from_user(sg_page(sg), sg->offset + sg_off,
> > -					      iov->iov_base + iov_off,
> > -					      to_copy);
> [...]
> 
> It looks like rds_page_copy{,_from,_to}_user() are all unused after this
> change, so you could delete them.

Maybe.  Or maybe add a saner wrapper for rds_page_copy_from_user()...  Separate
story, anyway.
