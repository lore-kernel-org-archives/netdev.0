From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Backporting the Linux kernel, for good - was: Re: semantic patch inference
Date: Fri, 9 Sep 2011 14:13:59 -0700
Message-ID: <CAB=NE6VVaAgyaEX0iTuuj=r1-Vsi5TgAyCj4+3J=QerrJTWs_Q@mail.gmail.com>
References: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
 <Pine.LNX.4.64.1109092245170.9242@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Andersen <jespera-dAYI7NvHqcQ@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.1109092245170.9242-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 9, 2011 at 1:48 PM, Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org> wrote:
> Thanks for your email. =C2=A0It made me realize that there was one th=
ing that I
> didn't understand at all.  If the patches are only intended to apply =
to
> linux-next, that makes the problem quite a bit simpler.

Awesome, and yes the patches/ are only targeted at applying onto
linux-next.git. When Linus decides to merge and out 3.x-rc1 I simply
then set $GIT_TREE to $HOME/linux-2.6-allstable/ and run the script to
suck code from there and apply patches from there.Turns out that
because the effort was done on linux-next and because linux-next will
look very much like what Linus ends up merging the patches/ will still
apply. So what I do then is simply create a branch for that target
stable kernel and keep refreshing the patches for that stable kernel
on that branch -- while the master branch keeps chugging along with
linux-next.

> I guess that the patch that spdiff will receive will already contain =
the
> appropriate #ifs, so we don't have to be concerned about them.

That is correct.

>=C2=A0We just add them in as is.

I do not follow, add what?

> There was also the question about one or multiple types of changes. =C2=
=A0I
> think this is not a problem, but Jesper should confirm. =C2=A0If a pa=
tch contains
> two changes and one can be generalized and the other one cannot for s=
ome
> reason, does spdiff give up on the whole thing, or does it do what it=
 can?
>
> Overall, the whole thing seems to be doable :)

Wow. I'm thrilled, so say the least.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
