From: Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: prevent task_cleanup running on freed xprt
Date: Tue, 03 Aug 2010 17:32:22 -0400
Message-ID: <1280871142.14520.7.camel@heimdal.trondhjem.org>
References: <20100803132453.4fa18444@tlielax.poochiereds.net>
	 <1280860815.9771.25.camel@heimdal.trondhjem.org>
	 <1280861363.12283.2.camel@heimdal.trondhjem.org>
	 <20100803212220.GI31579@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100803212220.GI31579-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-08-03 at 17:22 -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> We saw a report of a NULL dereference in xprt_autoclose:
> 
> 	https://bugzilla.redhat.com/show_bug.cgi?id=611938
> 
> This appears to be the result of an xprt's task_cleanup running after
> the xprt is destroyed.  Nothing in the current code appears to prevent
> that.
> 
> Signed-off-by: J. Bruce Fields <bfields-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ---

Thanks. Applied to nfs-for-2.6.36...

Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
