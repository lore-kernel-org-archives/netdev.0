From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC 1/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 11:40:45 -0700
Message-ID: <1305312045.8178.30.camel@Joe-Laptop>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
	 <1305303525-11113-2-git-send-email-roland@kernel.org>
	 <1305305065.8178.9.camel@Joe-Laptop>
	 <BANLkTikpzn6R-QH__dtmwz=fO1QMUN+qag@mail.gmail.com>
	 <1305308167.8178.20.camel@Joe-Laptop>
	 <BANLkTi=P7u2XPx+_F9d9waP5xuXqDYb5yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Nir Muchtar <nirm-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BANLkTi=P7u2XPx+_F9d9waP5xuXqDYb5yQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-05-13 at 20:12 +0200, Bart Van Assche wrote:
> On Fri, May 13, 2011 at 7:36 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > On Fri, 2011-05-13 at 19:18 +0200, Bart Van Assche wrote:
> > One long term goal for me is a generic run-time mechanism
> > to prefix all pr_<level> uses not just the <foo>_dbg ones
> > with or without module or function name.
> > It will also allow the removal of all the uses of
> > #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > New #define pr_fmt lines need to be added to the current
> > files that use pr_<level> without a prefix so it could
> > take awhile.
> Something like the +m flag documented in
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=Documentation/dynamic-debug-howto.txt;hb=HEAD
> ?

Yes, akin to that, but using /proc not debugfs.

Basically, just per module on/off prefixing of
module name and optionally function name via a
CONFIG_PR_LEVEL_STORE_FUNCTION_NAME.

I'd like to remove all current specific uses of
__func__ in pr_<level> and use per module
/proc controls to add them back as requested.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
