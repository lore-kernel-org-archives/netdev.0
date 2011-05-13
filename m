From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 09:38:18 -0400
Message-ID: <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com> <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Shuang He <shuang.he@intel.com>
To: Christian Couder <christian.couder@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 4:20 AM, Christian Couder
<christian.couder@gmail.com> wrote:
> On Thu, May 12, 2011 at 7:15 PM, Andrew Lutomirski <luto@mit.edu> wro=
te:
>>
>> OK, this sucks. =A0In the course of bisecting this, I've hit two oth=
er
>> apparently unrelated bugs that prevent my from testing large numbers
>> of kernels. =A0Do I have two questions:
>>
>> 1. Anyone have any ideas from looking at the log?
>>
>> It looks like most of what's left is network code, so cc netdev.
>>
>> 2. =A0The !&$#@ bisection is skipping all over the place. =A0I've se=
en
>> 2.6.37 versions and all manner of -rc's out of order. =A0Linus, and
>> other people who like pontificating about git bisection: is there an=
y
>> way to get the bisection to follow Linus' tree? =A0I think that if
>> bisect could be persuaded to consider only changes that are reached =
by
>> following only the *first* merge parent all the way from the bad
>> revision to the good revision, then the bisection would build versio=
ns
>> that were at least good enough for Linus to pull and might have fewe=
r
>> bisection-killing bugs.
>>
>> (This isn't a new idea [1], and git rev-list --bisect --first-parent
>> isn't so bad except that it doesn't bisect.)
>
> Did you forget to put the reference [1] in your email? Was it this on=
e
> you were thinking about:
>
> http://thread.gmane.org/gmane.comp.version-control.git/165433/

No, it was this:

http://stackoverflow.com/questions/5638211/how-do-you-get-git-bisect-to=
-ignore-merged-branches

--Andy

>
> ?
>
> Thanks,
> Christian.
>
