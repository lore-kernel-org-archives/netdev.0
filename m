From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] net/mac80211/rate.c: fix wrong sizeof()
Date: Thu, 10 Sep 2015 10:13:05 +0200
Message-ID: <1441872785.2108.2.camel@sipsolutions.net>
References: <1441832214-6939-1-git-send-email-slyich@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sergei Trofimovich <siarheit-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Lorenzo Bianconi <lorenzo.bianconi83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Trofimovich <slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441832214-6939-1-git-send-email-slyich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-09-09 at 21:56 +0100, Sergei Trofimovich wrote:
> From: Sergei Trofimovich <siarheit-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> Noticed by gcc-5.2.0:
> 
>     net/mac80211/rate.c: In function 'rate_control_cap_mask':
>     net/mac80211/rate.c:719:25: warning: 'sizeof' on array function 
> parameter 'mcs_mask' will return size of 'u8 * {aka unsigned char *}' 
> [-Wsizeof-array-argument]
>        for (i = 0; i < sizeof(mcs_mask); i++)
>                              ^
> 
We already merged a fix for this.

johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
