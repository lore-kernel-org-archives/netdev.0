From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 3/4] macvtap: Use iovec iterators
Date: Thu, 6 Nov 2014 17:33:33 +0000
Message-ID: <20141106173333.GZ7996@ZenIV.linux.org.uk>
References: <20141106082704.GB29800@gondor.apana.org.au>
 <E1XmIQW-0007mb-J4@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1XmIQW-0007mb-J4@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 04:28:20PM +0800, Herbert Xu wrote:

> +		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter))
>  			return -EFAULT;

Again, wrong calling conventions.  It returns how much has it copied.

> +		ret = copy_to_iter(&veth, sizeof(veth), iter);
> +		if (ret || !iov_iter_count(iter))
>  			goto done;
Ditto.
