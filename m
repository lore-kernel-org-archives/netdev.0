From: Ian Campbell <Ian.Campbell-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>
Subject: Re: [PATCH/RFC 0/10] enable SKB paged fragment lifetime visibility
Date: Fri, 15 Jul 2011 16:36:03 +0100
Message-ID: <1310744163.20648.21.camel@zakaz.uk.xensource.com>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
	 <20110715.081735.2057304107637222967.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110715.081735.2057304107637222967.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-15 at 16:17 +0100, David Miller wrote:
> From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> Date: Fri, 15 Jul 2011 12:06:46 +0100
> 
> > What is the general feeling regarding this approach?
> 
> Not bad,

Thanks, I'll continue in this direction then.

>  I like that only the users of destructors pay the price of
> the extra atomics.

Yes, I very much wanted to avoid hitting everyone with extra overhead.

> Like you say in patch #8, I wouldn't bother adding a whole new
> ->sendpage_destructor() OP, just add the new argument to the existing
> method.

Will do.

Ian.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
