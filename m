From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 01 Aug 2012 17:53:58 +0200
Message-ID: <1343836438.4638.5.camel@jlt3.sipsolutions.net>
References: <20120801131232.GA1785@zod.bos.redhat.com>
	 <20120801141810.GB27433@tuxdriver.com> <50194D7A.6060400@broadcom.com>
	 <5019506C.6020707@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Josh Boyer <jwboyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Roland Vossen <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5019506C.6020707-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-08-01 at 17:51 +0200, Arend van Spriel wrote:
> On 08/01/2012 05:38 PM, Arend van Spriel wrote:
> >> brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...
> >> > 
> >> > It looks like those calls were added in mid-June.
> >> > 
> > I think mid-june sounds about right. We never observed the warning when
> > changes to use regulatory infrastructure were tested/reviewed. Should
> > this precondition be mentioned in cfg80211.h?
> > 
> > Gr. AvS
> 
> Diving in further it seems brcmsmac can not grab the cfg80211_mutex. So
> another solution is needed.

Yeah I was going to say -- how can it possibly access that? It seems
that in some patch the API got broken, it should be taking the lock or
whatever ... I'll leave it to Luis to sort out though :-P

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
