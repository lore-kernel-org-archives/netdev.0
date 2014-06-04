From: Greg KH <greg@kroah.com>
Subject: Re: Stable backport of 2 igb fixes
Date: Tue, 3 Jun 2014 22:55:46 -0700
Message-ID: <20140604055546.GB20895@kroah.com>
References: <20140513095921.GC30843@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140513095921.GC30843@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 13, 2014 at 11:59:21AM +0200, Willy Tarreau wrote:
> Hi David,
> 
> could we please have the following patches backported to stable :
> 
>   cb06d102327 igb: Fix Null-pointer dereference in igb_reset_q_vector
>   b709323d247 igb: Unset IGB_FLAG_HAS_MSIX-flag when falling back to msi-only
> 
> This morning I experienced again that old kernel panic on 3.14.3 when
> loading igb on an ARM board without them.

I already picked these up, thanks.

greg k-h
