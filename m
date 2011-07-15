From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH/RFC 0/10] enable SKB paged fragment lifetime visibility
Date: Fri, 15 Jul 2011 08:17:35 -0700 (PDT)
Message-ID: <20110715.081735.2057304107637222967.davem@davemloft.net>
References: <1310728006.20648.3.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1310728006.20648.3.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Date: Fri, 15 Jul 2011 12:06:46 +0100

> What is the general feeling regarding this approach?

Not bad, I like that only the users of destructors pay the price of
the extra atomics.

Like you say in patch #8, I wouldn't bother adding a whole new
->sendpage_destructor() OP, just add the new argument to the existing
method.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
