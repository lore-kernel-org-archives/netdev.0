From: Thadeu Lima de Souza Cascardo <cascardo-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: linux-next: manual merge of the net-next tree with the
 infiniband tree
Date: Wed, 24 Apr 2013 14:53:04 -0300
Message-ID: <20130424175304.GA701@oc0268524204.ibm.com>
References: <20130418131843.bfeb6b1ad5fba1b0f706076e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130418131843.bfeb6b1ad5fba1b0f706076e-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 01:18:43PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> Today's linux-next merge of the net-next tree got a conflict in
> drivers/infiniband/hw/cxgb4/qp.c between commit 5b0c275926b8
> ("RDMA/cxgb4: Fix SQ allocation when on-chip SQ is disabled") from the
> infiniband tree and commit 9919d5bd01b9 ("RDMA/cxgb4: Fix onchip queue
> support for T5") from the net-next tree.
> 
> I think that they are 2 different fixes for the same problem, so I just
> used the net-next version and can carry the fix as necessary (no action
> is required).
> 
> -- 
> Cheers,
> Stephen Rothwell                    sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org


Commit 5b0c275926b8 also keeps the intention of the original patch which
broke it, which was to return an error code, in case the allocation fails.
Commit 9919d5bd01b9 fix will return 0 in case the allocation fails.

We should keep the other fix or fix the code again to return the proper
error code.

Regards.
Cascardo.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
