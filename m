From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/18] netdevice airo: Convert directly reference of
	netdev->priv to netdev->ml_priv
Date: Fri, 05 Sep 2008 13:06:23 -0400
Message-ID: <1220634383.6430.14.camel@localhost.localdomain>
References: <48C0A219.2030004@cn.fujitsu.com>
	 <48C0A72B.9050407@cn.fujitsu.com>  <20080905125036.GA3027@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080905125036.GA3027-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2008-09-05 at 08:50 -0400, John W. Linville wrote:
> On Fri, Sep 05, 2008 at 11:27:39AM +0800, Wang Chen wrote:
> > We have some reasons to kill netdev->priv:
> > 1. netdev->priv is equal to netdev_priv().
> > 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
> >    netdev_priv() is more flexible than netdev->priv.
> > But we cann't kill netdev->priv, because so many drivers reference to it
> > directly.
> > 
> > OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> > and I want to kill netdev->priv later, I decided to convert all the direct
> > reference of netdev->priv first.
> > 
> > Different to readonly reference of netdev->priv, in this driver, netdev->priv
> > was changed. I use netdev->ml_priv to replace netdev->priv.
> > 
> > Signed-off-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> 
> Thank you for your patch.  However, I do not understand why you didn't
> simply replace netdev->priv with netdev_priv()?  Can you explain?

Yeah, that would have been my first choice too...

Dan

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
