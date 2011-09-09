From: Julia Lawall <julia@diku.dk>
Subject: Re: Backporting the Linux kernel, for good - was: Re: semantic patch
 inference
Date: Fri, 9 Sep 2011 23:53:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1109092352230.13368@ask.diku.dk>
References: <CAB=NE6U0ks9CobukO04=bZpnkm3Yw+Pf7keVPsP-hv1NyJZ_Xw@mail.gmail.com>
 <Pine.LNX.4.64.1109092245170.9242@ask.diku.dk>
 <CAB=NE6VVaAgyaEX0iTuuj=r1-Vsi5TgAyCj4+3J=QerrJTWs_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1627508629-1315605207=:13368"
Cc: Jesper Andersen <jespera@diku.dk>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6VVaAgyaEX0iTuuj=r1-Vsi5TgAyCj4+3J=QerrJTWs_Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1627508629-1315605207=:13368
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 9 Sep 2011, Luis R. Rodriguez wrote:

> On Fri, Sep 9, 2011 at 1:48 PM, Julia Lawall <julia@diku.dk> wrote:
> > Thanks for your email.  It made me realize that there was one thing that I
> > didn't understand at all.  If the patches are only intended to apply to
> > linux-next, that makes the problem quite a bit simpler.
> 
> Awesome, and yes the patches/ are only targeted at applying onto
> linux-next.git. When Linus decides to merge and out 3.x-rc1 I simply
> then set $GIT_TREE to $HOME/linux-2.6-allstable/ and run the script to
> suck code from there and apply patches from there.Turns out that
> because the effort was done on linux-next and because linux-next will
> look very much like what Linus ends up merging the patches/ will still
> apply. So what I do then is simply create a branch for that target
> stable kernel and keep refreshing the patches for that stable kernel
> on that branch -- while the master branch keeps chugging along with
> linux-next.
> 
> > I guess that the patch that spdiff will receive will already contain the
> > appropriate #ifs, so we don't have to be concerned about them.
> 
> That is correct.
> 
> > We just add them in as is.
> 
> I do not follow, add what?

Sorry.  The + code. The #ifdefs ad the compatibility code.  We don't have 
to interpret it, so we don't care whether it is only related to kernel 
version numbers or something more complex.

julia

> > There was also the question about one or multiple types of changes.  I
> > think this is not a problem, but Jesper should confirm.  If a patch contains
> > two changes and one can be generalized and the other one cannot for some
> > reason, does spdiff give up on the whole thing, or does it do what it can?
> >
> > Overall, the whole thing seems to be doable :)
> 
> Wow. I'm thrilled, so say the least.
> 
>   Luis
> 
---511516320-1627508629-1315605207=:13368--
