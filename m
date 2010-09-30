From: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Fri, 1 Oct 2010 08:41:48 +1000
Message-ID: <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
References: <20100930211013.472957770@sipsolutions.net> <20100930211131.021309930@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	tgraf-G/eBtMaohhA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100930211131.021309930-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 1, 2010 at 07:10, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>=
 wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>
> Each family may have some amount of boilerplate
> locking code that applies to most, or even all,
> commands.
>
> This allows a family to handle such things in
> a more generic way, by allowing it to
> =A0a) include private flags in each operation
> =A0b) specify a pre_doit hook that is called,
> =A0 =A0before an operation's doit() callback and
> =A0 =A0may return an error directly,
> =A0c) specify a post_doit hook that can undo
> =A0 =A0locking or similar things done by pre_doit,
> =A0 =A0and finally
> =A0d) include two private pointers in each info
> =A0 =A0struct passed between all these operations
> =A0 =A0including doit(). (It's two because I'll
> =A0 =A0need two in nl80211 -- can be extended.)

Stupid question:

Why not have a priv struct rather than an arbitrary array of two pointe=
rs?

Thanks,

--=20

Julian Calaby

Email: julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Profile: http://www.google.com/profiles/julian.calaby/
=2EPlan: http://sites.google.com/site/juliancalaby/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
