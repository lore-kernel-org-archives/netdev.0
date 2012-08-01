From: "Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 21:28:48 +0200
Message-ID: <50198370.20304@broadcom.com>
References: <20120801131232.GA1785@zod.bos.redhat.com>
 <20120801141810.GB27433@tuxdriver.com> <50194D7A.6060400@broadcom.com>
 <5019506C.6020707@broadcom.com>
 <1343836438.4638.5.camel@jlt3.sipsolutions.net>
 <50196660.8090001@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Josh Boyer" <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Roland Vossen" <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Seth Forshee" <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"Luis R. Rodriguez" <rodrigue-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
To: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50196660.8090001-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2012 07:24 PM, Arend van Spriel wrote:
> It seems the API was as it currently is when adding regulatory framework
> changes in brcmsmac so we should have seen this assert flying by. The
> problem is that freq_reg_info() is exposed in cfg80211.h, but as it is
> now it can only be used under the cfg80211_mutex lock, ie. in regulatory
> notify callback (as Seth indicated).
> 
> Gr. AvS

Ah, I see you need to run a LOCKDEP-enabled kernel to get this warning.

Gr. AvS

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
