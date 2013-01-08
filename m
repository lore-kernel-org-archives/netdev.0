From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] sunrpc: verbs: Avoid 1kb stack
Date: Tue, 08 Jan 2013 10:09:36 -0800
Message-ID: <1357668576.12749.55.camel@joe-AO722>
References: <1357587696.21481.48.camel@joe-AO722>
	 <20130108144604.GB16343@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tom Tucker <tom-/Yg/VP3ZvrM@public.gmane.org>, steved-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Tom Talpey <ttalpey-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130108144604.GB16343-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-08 at 09:46 -0500, J. Bruce Fields wrote:
> On Mon, Jan 07, 2013 at 11:41:36AM -0800, Joe Perches wrote:
> > 16 * 64 is a bit much.
> > Use kmalloc_array instead.
> 
> I thought there was some reason we didn't do this.
> 
> Grepping up through the callers....  It looks like the result is
> xprt_rdma_send_request returns -EIO, and as far as I can tell that gets
> passed up to the application on the client.   That doesn't sound right.

No worries, it was just a warning I noticed when I
did an allmodconfig compilation.

Perhaps a comment there might be appropriate instead.


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
