From: Chao Bi <chao.bi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] WIFI: handle a neglected case in
 nl80211_new_interface()
Date: Thu, 28 Nov 2013 13:21:37 +0800
Message-ID: <1385616097.7437.8.camel@bichao>
References: <1385521254.23222.8.camel@bichao>
	 <CAE2MWk=WEwxbnBDhBRHKVQ7JhAwKANv-HQXyK=qTb4qaH4GZRg@mail.gmail.com>
	 <1385610818.7437.1.camel@bichao>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ujjal Roy <royujjal-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385610818.7437.1.camel@bichao>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-28 at 11:53 +0800, Chao Bi wrote:
> On Wed, 2013-11-27 at 20:43 +0530, Ujjal Roy wrote:
> > Hi,
> > 
> > 
> > We can use IS_ERR_OR_NULL(wdev) to check NULL as well as error value.
> > 
> > Thanks,
> > UjjaL
> > 
> > On Wed, Nov 27, 2013 at 8:30 AM, Chao Bi <chao.bi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> >         In nl80211_new_interface(), it calls rdev_add_virtual_intf() to create
> >         a new interface, however, it only checks whether returned value is err
> >         code, but doesn't check if returned value is NULL. The returned 
> 
> Thanks Ujjal. I'll update it.
> 
Hi all,
This patch is not valid, I further check the nl80211 API introduce,
don't need to handle this NULL return value because it bans NULL
feedback of add_virtual_intf() API in cfg80211.h.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
