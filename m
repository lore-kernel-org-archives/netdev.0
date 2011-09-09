From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: Re: Backporting the Linux kernel, for good - was: Re: semantic patch
 inference
Date: Fri, 9 Sep 2011 22:48:54 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1109092245170.9242@ask.diku.dk>
References: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Andersen <jespera-dAYI7NvHqcQ@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks for your email.  It made me realize that there was one thing that I
didn't understand at all.  If the patches are only intended to apply to
linux-next, that makes the problem quite a bit simpler.  I guess that the
patch that spdiff will receive will already contain the appropriate #ifs,
so we don't have to be concerned about them.  We just add them in as is.

There was also the question about one or multiple types of changes.  I
think this is not a problem, but Jesper should confirm.  If a patch contains
two changes and one can be generalized and the other one cannot for some
reason, does spdiff give up on the whole thing, or does it do what it can?

Overall, the whole thing seems to be doable :)

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
