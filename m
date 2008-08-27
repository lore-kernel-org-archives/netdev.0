From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 18:45:36 +0300
Message-ID: <1ba2fa240808270845k6000cb68o382111122ad3d069@mail.gmail.com>
References: <20080827013009.GA15781@tuxdriver.com>
	 <200808271510.35950.mb@bu3sch.de>
	 <1ba2fa240808270755t2f3d0c28rcb874011f5540ef3@mail.gmail.com>
	 <200808271722.55627.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Marcel Holtmann" <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200808271722.55627.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 6:22 PM, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> On Wednesday 27 August 2008 16:55:15 Tomas Winkler wrote:
>> I'm not sure what you are taking about, we did post patches to
>> wireless-testing, the driver for 5000 HW  is working in 2.6.27-rc4 I
>> personally use it every day.  I'm sending bug fixes, like this seris
>> of patches is direct answer to bugs that were discovered very
>> recently, I'm not sure what's everybody problem here.
>
> The problem is that these patches are posted in huge batches.
> There are three problems (probably more) with that:
> 1) "Oh, one of these 15 patches recently merged broke my hw"
>   instead of
>   "This patch XXX recently merged broke my hw"
> 2) It's a _lot_ harder to review. I do not have the time to review
>   a lot of patches at once. I bet other people won't either.
> 3) If somebody has any objections against one patch, you'll probably
>   have to rebase them all (See recent pull request vs cleanups).
>   That's additional work for you.
>
> What's the problem with sending patches upstream as soon as you finished
> them, instead of piling them up locally and sending them alltogether?

First of all, mac patches are send immediately to wireless-dev for
review just because we don't want to break anyone works (just look at
the archives).  iwlwifi patches are sent first to internal mailing
list for review and internal testing because nobody is really
reviewing these patches in wireless-dev and this is common practices
(see latest orinoco 19 patches dump) Internal mailing list is
really the only place I'm getting any feedback on iwlwifi code, they
are few exception of course.
Second I'm not sure why Yi is sending them only once a week I thought
he had some agreement with John, really don't know.

>> We fixed bugs in wireless-testing/mac80211 that were there for months
>> just because we are only one that do any comprehensive validation. I
>> don't  want insult anyone and I really exaggeration here but
>> sometimes I have feeling that more people are breaking the code.
>
> If you work directly upstream, you will discover these bugs even faster.
> If you maintain your local fork of mac80211, you will have a delay. But
> you will have to handle them _anyway_. It's just delayed.

For exact reason we delay patches to 2.6.28, too keep stable.

>
> And please, don't act like you don't add bugs to mac80211. There were several
> bugs that broke connections on b43 (and probably other hw, too) in the past.

Not sure what exact patches are you referring to but I do a lot of
bugs no doubt and I really test only iwlwifi but we do broad features
testing  IIRC I did IBSS test with b43 it's broken same way is iwlwifi
(look for TSF bug fix)
Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
