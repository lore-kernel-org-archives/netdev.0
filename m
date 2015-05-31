From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Sun, 31 May 2015 11:54:50 +0900
Message-ID: <20150531025450.GA10754@kroah.com>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <55634793.4050002@lwfinger.net>
 <20150531025347.GA8074@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Haggi Eran <haggai.eran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20150531025347.GA8074-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 31, 2015 at 11:53:47AM +0900, Greg KH wrote:
> On Mon, May 25, 2015 at 11:02:27AM -0500, Larry Finger wrote:
> > On 05/23/2015 04:16 PM, Larry Finger wrote:
> > >The driver is reporting a warning at kernel/time/timer.c:1096 due to calling
> > >del_timer_sync() while in interrupt mode. Such warnings are fixed by calling
> > >del_timer() instead.
> > >
> > >Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> > >Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> > >Cc: Haggi Eran <haggai.eran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > >---
> > 
> > Greg,
> > 
> > Please drop this patch. The same fixes were submitted as
> > https://lkml.org/lkml/2015/5/15/226.
> 
> That's not working for me at the moment, what was the subject: name?  I
> think I already applied it to the testing tree...

Nevermind, found it...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
