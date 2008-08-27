From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-08-26
Date: Wed, 27 Aug 2008 15:26:17 +0300
Message-ID: <1ba2fa240808270526g163f8c0an3c5d220cce69466c@mail.gmail.com>
References: <1ba2fa240808270305m7f505efak9fd0d36d5db09a1e@mail.gmail.com>
	 <1219831828.3891.3.camel@johannes.berg>
	 <1ba2fa240808270434y1589761xd2ff0a48c2e99033@mail.gmail.com>
	 <20080827.044551.102233262.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080827.044551.102233262.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 27, 2008 at 2:45 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 27 Aug 2008 14:34:28 +0300
>
>> Unfortunately fixing bugs on stable branch take precedence  of
>> adjusting to new API on development branch that someone decided to do.
>>  I wanted to work directly on wireless testing but it was broken over
>> an over and I have only limited resources more in testing then in
>> development I just had to branch out to be ready with the driver when
>> HW is out. People just check the immediate impact of they fix the
>> don't test for collateral damage and this is understandable an
>> individual developer doesn't have lab with IBSS, BSS, AP, etc setups.
>
> But think about this from the other perspective.
>
> When you queue up tons of things, especially in infrastructure level
> code such as mac80211, and on top of it you do your work on the stable
> branch and do not do you work against the development tree, guess what
> happens?

> You show up with accumulated piles of non-trivial patches for people
> to review.  And then you'll get upset when they suggest that things be
> implemented differently.

I never worked that way I've published immediately what I had. I don't
know where  did you get this impression
 If I didn't publish something it's just too reasons.
The code was made dirty and I didn't like design myself (for example
our 11h implementation), even though it's publicly available.
or just simply didn't have time because I have to satisfy first thous
who pays my check ( everybody to feed their children after all:) )
(e.g. rfkill fixes)
Almost every driver has it's own development branch, we didn't do
something different here, this is just classical divide and conquer
strategy.

> It's all because of the gap in time.
>
> And during this time, if you had submitted earlier, you would end up
> doing smaller and mode gradual modifications to your design.  And
> you'd take care of them before they effect subsequent pieces of work
> you want to do which depend upon the earlier bits.
>
> The longer you queue stuff up, the more painful having to change stuff
> at the beginning of that queue becomes.  It can invalidate everything
> else you worked on.
>
> The only sane way to operate is to post your work early and often, or
> else you'll live in a world of hurt, and it will be nobody's fault but
> your own.

This is all understood and this would be indeed the ideal case.
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
