From: Stefano Stabellini <sstabellini@kernel.org>
Subject: Re: [PATCH net-next] xen/9pfs: p9_trans_xen_init and p9_trans_xen_exit
 can be static
Date: Thu, 18 May 2017 11:40:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1705181138590.6833@sstabellini-ThinkPad-X260>
References: <20170518152241.4830-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Stefano Stabellini <sstabellini@kernel.org>,
        Juergen Gross <jgross@suse.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
        boris.ostrovsky@oracle.com, jgross@suse.com
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:36476 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753965AbdERSkx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 14:40:53 -0400
In-Reply-To: <20170518152241.4830-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 May 2017, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fixes the following sparse warnings:
> 
> net/9p/trans_xen.c:528:5: warning:
>  symbol 'p9_trans_xen_init' was not declared. Should it be static?
> net/9p/trans_xen.c:540:6: warning:
>  symbol 'p9_trans_xen_exit' was not declared. Should it be static?
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Stefano Stabellini <sstabellini@kernel.org>

If that's OK for everybody we'll queue this fix and
20170516142247.12301-1-weiyj.lk@gmail.com to the xentip tree.


> ---
>  net/9p/trans_xen.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
> index 71e8564..3deb17f 100644
> --- a/net/9p/trans_xen.c
> +++ b/net/9p/trans_xen.c
> @@ -525,7 +525,7 @@ static struct xenbus_driver xen_9pfs_front_driver = {
>  	.otherend_changed = xen_9pfs_front_changed,
>  };
>  
> -int p9_trans_xen_init(void)
> +static int p9_trans_xen_init(void)
>  {
>  	if (!xen_domain())
>  		return -ENODEV;
> @@ -537,7 +537,7 @@ int p9_trans_xen_init(void)
>  }
>  module_init(p9_trans_xen_init);
>  
> -void p9_trans_xen_exit(void)
> +static void p9_trans_xen_exit(void)
>  {
>  	v9fs_unregister_trans(&p9_xen_trans);
>  	return xenbus_unregister_driver(&xen_9pfs_front_driver);
> 
