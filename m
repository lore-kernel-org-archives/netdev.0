From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Mon, 19 May 2008 11:53:58 -0400
Message-ID: <1211212438.12187.13.camel@localhost.localdomain>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 (sfid-20080517_154639_384202_6D3479C2)  <1211032475.6252.2.camel@johannes.berg>
	 <1211117795.686.15.camel@localhost.localdomain>
	 <1211199368.6252.19.camel@johannes.berg>
	 <1211210686.12187.6.camel@localhost.localdomain>
	 <1211211547.6252.54.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1211211547.6252.54.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-05-19 at 17:39 +0200, Johannes Berg wrote:
> On Mon, 2008-05-19 at 11:24 -0400, Dan Williams wrote:
> > On Mon, 2008-05-19 at 14:16 +0200, Johannes Berg wrote:
> > > > Instead of testing for wireless/, best thing would probably be to call
> > > > SIOCGIWRANGE on the device and if it returns EOPNOTSUP then it's not
> > > > wireless.  Some drivers may have to load firmware to figure out
> > > > supported rates and encryption capabilities, but to be honest, NM does
> > > > this to detect wireless devices and I haven't run into any issues in 4
> > > > years using it.  If there are issues with drivers, then we need to fix
> > > > the driver too.
> > > 
> > > I was about to propose calling SIOCGIWNAME since that is what
> > > wireless-tools do and that linux/wireless.h indicates.
> > 
> > Hmm; NAME is pretty useless.  That's fine to do, I guess WEXT requires
> > that NAME return _something_ at least.  NAME should never ever be used
> > for anything more, but since wireless-tools appears to do this that's
> > fine.
> 
> Yes, I realise it is completely useless, but wext seems to require that
> it be implemented. RANGE would work as well but typically has much more
> complexity in the kernel.

Yup; NAME's better for this even though it's useless.

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
