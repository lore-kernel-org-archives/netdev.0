From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: Possible regression with skb_clone() in 2.6.36
Date: Tue, 21 Sep 2010 01:10:39 -0300
Message-ID: <20100921041039.GA8978@vigoh>
References: <1283209824-8795-1-git-send-email-padovan@profusion.mobi>
 <20100917153440.474b93e4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100917153440.474b93e4.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> [2010-09-17 15:34:40 -0700]:

> On Mon, 30 Aug 2010 20:10:23 -0300
> "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org> wrote:
> 
> > I've been experiencing some problems when running the L2CAP Streaming mode in
> > 2.6.36. The system quickly runs in an Out Of Memory condition and crash. That
> > wasn't happening before, so I think we may have a regression here (I didn't find
> > where yet). The crash log is below.
> 
> So 2.6.35 was OK?
> 
> > The following patch does not fix the regression, but shows that removing the
> > skb_clone() call from l2cap_streaming_send() makes the problem goes away. The
> > patch is good anyway since it saves memory and time when sending Streaming mode
> > packets.
> 
> How does "make it go away" differ from "fix the regression" :)
> 
> But yes, if we don't understand the source of the bug then it may well
> still be there.  Did you make any progress in understanding the cause?

I did some progress and found that this really fix the bug. We are fine
here then. :)

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
