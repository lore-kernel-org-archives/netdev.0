From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH 06/10] mac802154: add a software MAC 802.15.4
	implementation
Date: Fri, 5 Jun 2009 14:24:56 +0200
Message-ID: <20090605122456.GA1717@ucw.cz>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-4-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-5-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-6-git-send-email-dbaryshkov@gmail.com> <1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org,
	maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org, dmitry.baryshkov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org,
	oliver.fendt-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org
To: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1243868091-5315-7-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon 2009-06-01 18:54:47, Dmitry Eremin-Solenikov wrote:
> Some of available devices are just dump radios implementing IEEE 802.15.4
> PHY layer. This commit adds a common library that acts like an intermediate
> layer between our socket family and drivers for those dumb devices.
> 
> Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
> ---
>  include/net/ieee802154/mac802154.h |   79 ++++

Could we get some name that is not alphabet soup? Is 'zigbee'
trademarked so heavily that it can't be used? Maybe 'wpan'?
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
