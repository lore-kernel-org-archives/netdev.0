From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 12:06:58 -0600
Message-ID: <CAMP44s1yJMd+9G5yu988GqafRYnAteN-y-WWDe-rJh_qQpSPkQ@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
	<CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	<1384188067.14334.45.camel@jlt4.sipsolutions.net>
	<CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
	<1384189227.14334.48.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384189227.14334.48.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 11:00 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Mon, 2013-11-11 at 10:53 -0600, Felipe Contreras wrote:

>> > Like I said before - trying to work with an AP without beacons at all is
>> > really bad, we shouldn't be doing it.
>>
>> Why not? For all intents and purposes my system is not receiving any
>> beacons, and I don't see any problems.
>
> The not receiving part is a bug. I think you're probably receiving
> beacons once associated though?

Nope. Never.

>> What would you prefer? That nothing works at all?
>
> Yes, that'd be much safer.

How exactly?

>> > We might not properly react to
>> > radar events, and other things, for example.
>>
>> So? I don't know what that means, but it can't be worst than not being
>> able to connect to the Internet whatsoever at all.
>
> It can make you break the law.

How?

I'm reading this document[1], and if that's what you are referring to,
then for starters it only applies to the master mode, my patch changes
the behavior only on station mode.

Moreover, if continuing the association without beacons has a legal a
problem, that problem would exist for drivers that don't have the
IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC flag, wouldn't it? How exactly
would trying to associate with need_beacon break the law, but not if
!need_beacon?

[1] http://wireless.kernel.org/en/developers/DFS

-- 
Felipe Contreras
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
