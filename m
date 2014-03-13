From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Wed, 12 Mar 2014 18:21:35 -0700
Message-ID: <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com> <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org> <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394673476.32465.215.camel-Hs+ccMQdwurzDu64bZtGtWD2FQJk+8+b@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 6:17 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On Wed, 2014-03-12 at 14:19 -0700, Andy Lutomirski wrote:
>> On Wed, Mar 12, 2014 at 2:16 PM, Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> >
>> > Connection time is all we do and can care about.
>>
>> You have not answered why.
>
> We are going to disclose information to the peer based on policy that
> depends on the cgroup the peer is part of. All we care for is who opened
> the connection, if the peer wants to pass on that information after it
> has obtained it there is nothing we can do, so connection time is all we
> really care about.

Can you give a realistic example?

I could say that I'd like to disclose information to processes based
on their rlimits at the time they connected, but I don't think that
would carry much weight.

--Andy
