From: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Mon, 15 Jun 2009 22:40:08 +0200
Message-ID: <69e28c910906151340s44cafc35rdca24530fbae755@mail.gmail.com>
References: <1245096771-3966-1-git-send-email-lrodriguez@atheros.com>
	<1245097883.10970.5.camel@mj>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	greg@kroah.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tshibata@ab.jp.nec.com
To: Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:50885 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbZFOUql convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 16:46:41 -0400
In-Reply-To: <1245097883.10970.5.camel@mj>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 10:31 PM, Pavel Roskin<proski@gnu.org> wrote:
> On Mon, 2009-06-15 at 16:12 -0400, Luis R. Rodriguez wrote:
>>
>> +Stable kernel releases
>> +----------------------
>> +
>> +Stable kernels are released when they are ready. This means there i=
s no
>> +strict guidelines for sticking to specific dates for a kernel relea=
se.
>
> there are no strict guidelines
>
>> +After a maintainer has sent his pull request to Linus during the me=
rge
>> +window no further new development will be accepted for that tree an=
d
>> +as such it marks the closure of development for that subsystem for =
that
>> +kernel cycle. Developers wishing to target deadlines should simply =
work
>> +on their development without regards or consideration for inclusion=
 to
>> +a specific kernel release. Once development is done it should simpl=
y be
>> +posted. If you insist on targetting a kernel release for deadlines =
you can
>
> targeting
>
>> +try to be aware of the current rc cycle development and how soon it=
 seems
>> +the next stable kernel relase will be made. When Linus notes the la=
st rc
>
> release
>
>> +cycle released may be the last -- that is a good sign you should al=
ready
>> +have all your development done and merged in the respective develop=
ment
>> +tree. If your code is not ready and merged into the respective main=
tainers
>> +tree prior to the announced last potential rc kernel release chance=
s are
>> +you missed getting your code in for the next kernel merge window.
>> +Excemptions here are new drivers, covered below.
>
> Exemptions
>
>> +rc-series rules
>> +---------------
>> +
>> +Rules on what kind of patches are accepted after the merge window c=
loses.
>> +These are patches targetted for the kernel rc-series of a kernel pr=
ior
>
> targeted
>
>> +to its release.
>> +
>> + - it must fix a reported regression
>> + - if must fix a reported security hole
>> + - if must fix a reported oops/kernel hang
>> +
>> +This means any small-non-fix code changes, although they mix fix an=
 issue,
>
> might fix
>
>> +will not be accepted. If the patch in question is for a driver that=
 has been
>> +around for more than a kernel release, then "small fixes" really ca=
n't be
>> +worth all that much. And "small fixes" may be small and "obvious" t=
hey
>> +definitely can regress.
>> +
>> +rc-series new driver excemption rule
>
> exemption
>
>> +------------------------------------
>> +
>> +The very first release a new driver (or filesystem) is special. New=
 drivers
>> +are accepted during the rc series. Patches for the same driver then=
 are
>> +also accepted uring the same rc series of a kernel as well as fixes=
 as it
>
> during
>
>> +cannot regress as no previous kernels exists with it.
>> +
>> +Once drivers are upstream for one kernel release (say on 2.6.29) th=
e target
>> +*goal* after the merge window of the next kernel (respectively this=
 would be
>> +the 2.6.30 rc-series) is to address address regressions. Kernel oop=
s/hangs
>
> s/address address/address/
>
>> +and security issues are obviously accepted but the point is these s=
hould have
>> +also been caught earlier as a general development goal. The rc-seri=
es focus
>> +should really be to address regressions.
>> +
>> +Stable kernel rules
>> +-------------------
>> +
>> =A0Rules on what kind of patches are accepted, and which ones are no=
t, into the
>> =A0"-stable" tree:
>
> Sorry, I'm in pedantic mood today.

At least you didn't end up making a spelling error in any of your
corrections. :-)

>
> --
> Regards,
> Pavel Roskin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wirel=
ess" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Vista: [V]iruses, [I]ntruders, [S]pyware, [T]rojans and [A]dware. :-)
