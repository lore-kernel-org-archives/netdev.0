From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 18:17:20 -0500
Message-ID: <1171063040.7039.16.camel@dv>
References: <45CCE3CA.4050904@linux.intel.com> <1171061021.7039.7.camel@dv>
	 <45CCF318.2020503@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCF318.2020503-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-09 at 14:18 -0800, James Ketrenos wrote:
> Updated and tested 'git clone' and its working now (I use cg-clone)

Thanks.  It's working for me too.

> > grep: /lib/modules/2.6.20/build//include/linux/netdevice.h: No such file
> > or directory
> > 
> > Apparently it should be looking into /lib/modules/2.6.20/source as well.
> > That was a problem with the official ipw3945 drivers as well.
> 
> I'll look into it.  Does it work if you explicitly set KSRC to point to 
> your kernel sources?
> 
> $ make KSRC=/lib/modules/2.6.20/source

That works.  At least it doesn't report errors.  But it doesn't create a
single object file.  Anyway, I'm cheating here - my kernel does include
d80211 support.

"build" is still hardcoded in iwlwifi's Makefile.  It's interesting that
D80211_INC is defined twice in Makefile.  That must be wrong.

I'm going to try everything on a more traditional build in the tree and
without d80211.  And then I'll try to break some assumptions.

-- 
Regards,
Pavel Roskin

-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
