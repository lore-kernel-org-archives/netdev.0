From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 10:53:22 -0700
Message-ID: <CALCETrX3srGgO4kSueBOYrFSi5__LoHEExis8uvCE+hwgUTdiw@mail.gmail.com>
References: <CALCETrURHNmLyccRiF_W8o2ozRMR4AaCjUE=_PU8z1+Pq6X2jQ@mail.gmail.com>
 <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <1397667766.19767.440.camel@willson.li.ssimo.org> <CALCETrU_yKQVZyVug25cxwQFjWJ7Zf20FY-6ht+RJifXtDdDWg@mail.gmail.com>
 <1397669685.19767.450.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1397669685.19767.450.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 10:34 AM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, 2014-04-16 at 10:29 -0700, Andy Lutomirski wrote:
>> Then please remove SO_PASSCGROUP.
>
> Can you stop demanding changes while demonstrating you haven't well
> understood the needs, let alone the consequences ?
>
> Take a day or 2, put your thoughts together and come back with a clear
> description of your concerns if you still have any, please.

OK, if one of you can give a description of what the needs are.  So
far, I've heard:

SSSD, but there was already a longish thread on why SSSD could solve
all of its problems without any kernel changes at all.  I didn't see a
compelling answer there.

journald for things in containers, but this doesn't seem to me to
require any help from the kernel.

journald for things not in containers.  This one is legit, although it
can be solved, albeit with some races, in current kernels.  Is this
the only example?

--Andy
