From: "Tomas Winkler" <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: pull request: wireless-2.6 2008-11-18
Date: Wed, 19 Nov 2008 18:51:49 +0200
Message-ID: <1ba2fa240811190851i5dda6734w10d38b0f27e5ac97@mail.gmail.com>
References: <20081119000719.GA19756@tuxdriver.com>
	 <1ba2fa240811182246m17a6baf0ybde19af030a65819@mail.gmail.com>
	 <1ba2fa240811190134u7974a840i532e8ed0e18f8c72@mail.gmail.com>
	 <20081119143919.GA3485@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20081119143919.GA3485-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2008 at 4:39 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Wed, Nov 19, 2008 at 11:34:37AM +0200, Tomas Winkler wrote:
>> On Wed, Nov 19, 2008 at 8:46 AM, Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> > On Wed, Nov 19, 2008 at 2:07 AM, John W. Linville
>> > <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>
>> >>      mac80211: remove ieee80211_notify_mac
>> >>      iwlagn: fix RX skb alignment
>> >
>> > IMHO its premature pushing ttese 2 patches up, they came in yestrday
>> > and nobody here has run tthe code
>
> Well, thanks for your opinion.  Here is mine:
>
> The iwlwifi drivers have been hitting these problems for months,
> and I have seen no effort by your team to address the problems.

There is a lot of effort to solve this I'm not sure what mailing list
are u reading.
We even presented test patches with alignment issues as Johannes few
month ago but
we didn't get the feedback that it hit anything. So you are totally off here.

> It is possible that your team is working on them behind closed doors
> and will eventually throw something over the wall to us.  I'm tired
> of waiting for that, and I imagine that hordes of iwlagn users are
> tired of waiting as well.

This is embarrassing also for us that we cannot locate this specific
problem but it not like we are not doing anything.Not sure there are
other examples that we are not addressing bugs promptly.

> Johannes has presented us with plausible fixes, and people are
> reporting that the patches work for them.

I'm not against merging these patches to wireless-testing but pushing
them upstream before testing them
is just plainly wrong and all I asked for to test them. You are
presenting here double standards here.

 I can merge these patches,
> or wait/hope/pray for some to come from your team.  Experience suggests
> that if fixes do come from your team that they will either be buried
> in some monster patch that largely addresses something else, or
> that the patches will arrive with a changelog that is terse and/or
> unintelligble.  Subsequently, I am not optimistic about waiting.

I've believe that we are addressing all the complains above and
currently  if you are not seeing this I'm really sorry.

> I think Johannes cited four different bugzilla.kernel.org entries
> between those two patches.  What is your team doing to address
> those bugs?

Again you are not reading the mailing list and not the bugs logs.

>
> Obviously, I still think that those patches should be merged.

I'm not against just give it day or two to run it.  We have for
example nightly regression builds with publicly available results why
you cannot wait till we can run?  I think you've hurried to push it up
just as a statement forgetting of possible regressions.

>
>> Just checked our bug database,  the ieee80211_notify_mac was
>> introduced mainly to overcome HW bug when
>> receiver become deaf  in heavy traffic such as ftp in noisy
>> environment. Otherwise reconnection was too slow to keep ftp going. We
>> need to check whether we are still hitting this before applying
>> removal this function
>
> You are welcome to submit patches that address your hardware issue
> and which do not introduce locking problems.

That was my suggestion that we fix it and I believe  we have normal
discussion about it till you took your eager pushing steps. Replacing
one regression with another is just not sane.

Thanks
Tomas
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
