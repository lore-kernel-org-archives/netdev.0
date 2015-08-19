From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2015-08-19
Date: Wed, 19 Aug 2015 14:13:46 +0300
Message-ID: <87bne3a5ud.fsf@kamboji.qca.qualcomm.com>
References: <87pp2ja6ar.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87pp2ja6ar.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org> (Kalle Valo's message
	of "Wed, 19 Aug 2015 14:03:56 +0300")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:

> here's one more pull request for 4.3. More info in the signed tag below.
>
> This time I had to merge mac80211-next.git due to some iwlwifi
> dependencies and apparently that broke git-request-pull's diffstat
> again, it was showing changes which were not really coming from my tree.
> I think that's just a bug in my old git and really should update the
> tool. This time I just fixed the diffstat manually.
>
> But please be extra careful with this pull request and please let me
> know if you have any problems.

Oh, I forgot to mention that I saw this build error when I did a test
merge:

net/ipv4/fib_semantics.c:553:3: error: implicit declaration of function lwtstate_free [-Werror=implicit-function-declaration]

But I see that also with unmodified net-next so I'm assuming I didn't
cause that :)

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
