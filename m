From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH] ieee80211_if_set_type: make check for master dev more
	explicit
Date: Thu, 4 Oct 2007 15:13:01 -0400
Message-ID: <20071004191301.GJ6037@tuxdriver.com>
References: <20071004113343.552139D502B@zog.reactivated.net> <20071004180900.GG6037@tuxdriver.com> <1191523488.7367.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1191523488.7367.16.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 08:44:48PM +0200, Johannes Berg wrote:
> On Thu, 2007-10-04 at 14:09 -0400, John W. Linville wrote:
> 
> > --- a/net/mac80211/ieee80211_iface.c
> > +++ b/net/mac80211/ieee80211_iface.c
> > @@ -106,7 +106,7 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
> >  	 * which already has a hard_start_xmit routine assigned
> >  	 * which must not be changed.
> >  	 */
> > -	if (!dev->hard_start_xmit)
> > +	if (dev->type != ARPHRD_IEEE80211)
> >  		dev->hard_start_xmit = ieee80211_subif_start_xmit;
> 
> That should work as well although I think you should update the comment
> above :)

The comment still seem applicable.  How would you word it?

-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
