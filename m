From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Wed, 21 May 2008 17:03:52 -0400
Message-ID: <20080521210352.GA11827@tuxdriver.com>
References: <1211026337.3827.25.camel@johannes.berg> <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org> <1211303731.6252.105.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1211303731.6252.105.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 20, 2008 at 07:15:31PM +0200, Johannes Berg wrote:
> On Sat, 2008-05-17 at 15:45 +0200, Marcel Holtmann wrote:
> > Hi Johannes,
> > 
> > > The /sys/class/net/*/wireless/ direcory is, as far as I know, not
> > > used by anyone. Additionally, the same data is available via wext
> > > ioctls. Hence the sysfs files are pretty much useless. This patch
> > > makes them optional and schedules them for removal.
> > 
> > it is used by HAL to classify WiFi network cards as net.80211 instead  
> > of net.80203 and so we do have an actual user. However HAL only tests  
> > for the existence of the directory wireless/.
> > 
> > Please fix HAL first before submitting such a patch.
> 
> I have filed a patch to fix HAL to use the canonical SIOCGIWNAME at
> https://bugs.freedesktop.org/show_bug.cgi?id=16037. Any further
> objections to this patch?

I think this is going to fall under the "userland ABI" category.
We can make it a configurable option, but I don't think we are free
to remove it completely since there is at least existing versions of
HAL that use it.

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
