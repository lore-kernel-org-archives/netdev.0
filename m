From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: : Emit event stream compat iw_point objects correctly.
Date: Tue, 03 Jun 2008 10:37:16 -0700 (PDT)
Message-ID: <20080603.103716.193719039.davem@davemloft.net>
References: <20080110.011602.74511551.davem@davemloft.net>
	<20080111112248.610C.40F06B3A@sm.sony.co.jp>
	<20080603.095750.120470495.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080603.095750.120470495.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Date: Tue, 03 Jun 2008 09:57:50 -0700 (PDT)

> From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
> Date: Fri, 11 Jan 2008 13:16:29 +0900
> 
> > The source address does not have to be adjusted.  I think it should be
> > 		       ((char *) iwe) + IW_EV_LCP_LEN,
> > or just
> > 		       &iwe->u
> > I think it is more readable what we want to do here.
> > 
> > 
> > > +		       event_len - lcp_len);
> > 
> > The length of the real payload does not need to take account of the
> > destination offset change.  So we can keep the original code like:
> > 
> > 		       org_event_len - IW_EV_LCP_LEN);
> 
> As long as IW_EV_LCP_LEN and IW_EV_COMPAT_LCP_LEN are different, I am
> pretty sure we need to make these adjustments.
> 
> There are so many differences in how struct vs. sub-struct alignment will
> occur in these cases, that we need to be very careful.
> 
> I'll try to look more closely at this and do some testing of my own on
> a compat platform.

I know understand what you were trying to say, indeed the source
address does not and should not need to be adjusted, it is in
non-compat format afterall.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
