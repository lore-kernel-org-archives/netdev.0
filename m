From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 09:39:14 -0400
Message-ID: <BANLkTinoGfj1NUzTveSH0vgwZczCaFr8HA@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com> <BANLkTi=YDZa+BRaG90vJsjrT9VxgySrDRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=YDZa+BRaG90vJsjrT9VxgySrDRQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[resend because the Android gmail client apparently generates HTML
emails even for plain text]

On Thu, May 12, 2011 at 1:37 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Thu, May 12, 2011 at 10:15 AM, Andrew Lutomirski <luto@mit.edu> wr=
ote:
>>
>> OK, this sucks. =A0In the course of bisecting this, I've hit two oth=
er
>> apparently unrelated bugs that prevent my from testing large numbers
>> of kernels. =A0Do I have two questions:
>>
>> 1. Anyone have any ideas from looking at the log?
>
> Nope, that doesn't look very helpful.
>
>> 2. =A0The !&$#@ bisection is skipping all over the place. =A0I've se=
en
>> 2.6.37 versions and all manner of -rc's out of order.
>
> That's the _point_ of bisection. It jumps around. You can start off
> trying to pick points on my development tree, but I only have a
> hundred merges or so. You're going to start delving into the actual
> development versions very quickly. And if you don't do it early,
> bisection is going to be much much slower, because it's not going to
> pick half-way points.
>
> So bisection works so well exactly because it picks points that are
> far away from each other, and you should just totally ignore the
> version number. It's meaningless. Looking at it just confuses you.
> Don't do it.
>

I actually had better results looking at the version number, saying
"blech", and running git merge v2.6.38.  (git bisect good gets a
little confused if I feed it the merge result, but I can just lie.)

Anyway, I must have made a mistake somewhere.  The regression is in
drm (presumably i915) and it has a new thread now.

--Andy
