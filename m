From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Wed, 27 Nov 2013 00:44:36 -0600
Message-ID: <CAMP44s0y+YTSMdWMB5fBsa4UdBUB5ccXR5a-GL-10L807aCT9w@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
	<CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	<1384188067.14334.45.camel@jlt4.sipsolutions.net>
	<CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
	<1384189227.14334.48.camel@jlt4.sipsolutions.net>
	<CAMP44s1yJMd+9G5yu988GqafRYnAteN-y-WWDe-rJh_qQpSPkQ@mail.gmail.com>
	<1384367422.14578.20.camel@jlt4.sipsolutions.net>
	<CAMP44s1orLwg4v8UPM_1c-PspKQd5run_wAwHj-8oKmj2uqUgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMP44s1orLwg4v8UPM_1c-PspKQd5run_wAwHj-8oKmj2uqUgw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 14, 2013 at 4:44 AM, Felipe Contreras
<felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Wed, Nov 13, 2013 at 12:30 PM, Johannes Berg
> <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

>> In any case, I'm not really comfortable connecting to an AP that we
>> never ever receive beacons from.
>
> Well, we are *already* doing that for every driver, except the ones
> that do IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC, which are few.

Since you didn't reply I'm going to arrive to the obvious conclusion;
we *already* connect to APs even if we don't receive any beacons, my
patch simply makes it consistent for the drivers that set
IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC.

Therefore all your reasons to not apply the patch have been dismissed.

-- 
Felipe Contreras
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
