From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: A generic kernel compatibilty code
Date: Fri, 20 Nov 2009 16:18:38 -0500
Message-ID: <20091120211837.GA22815@tuxdriver.com>
References: <43e72e890911201245r4de5b039hb2dd5011dabf2399@mail.gmail.com> <43e72e890911201251t6210ee19n177eaf003a4fffc@mail.gmail.com> <43e72e890911201253obc466c8k2102e04457c48c92@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756158AbZKTVag@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43e72e890911201253obc466c8k2102e04457c48c92@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2009 at 12:53:51PM -0800, Luis R. Rodriguez wrote:
> On Fri, Nov 20, 2009 at 12:51 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> > On Fri, Nov 20, 2009 at 12:45 PM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> >> Everyone and their mother reinvents the wheel when it comes to
> >> backporting kernel modules. It a painful job and it seems to me an
> >> alternative is possible. If we can write generic compatibilty code for
> >> a new routine introduced on the next kernel how about just merging it
> >> to the kernel under some generic compat module. This would be
> >> completey ignored by everyone using the stable kernel but can be
> >> copied by anyone doing backport work.
> >>
> >> So I'm thinking something as simple as a generic compat/comat.ko with
> >> compat-2.6.32.[ch] files.
> >
> > FWIW, I meant a compat-2.6.32.[ch] and compat-2.6.31.[ch] and so on.
> > All these would link to the compat.ko
> 
> I supose this could juse be a separate tree with some generic
> compat.ko module. That might work better.

This is what I would suggest for pursuing this idea.  Perhaps you
could split-off from compat-wireless, then make that tree depend on
the new tree (compat-core?)...

Hth...

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
