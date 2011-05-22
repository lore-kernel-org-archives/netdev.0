From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Adding syscalls (was: Re: [GIT PULL] Namespace file descriptors for 2.6.40)
Date: Sun, 22 May 2011 10:15:23 +0200
Message-ID: <BANLkTikf7M_yTFe2fZx63HSDYFjhT_+soA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-arch@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 22, 2011 at 02:33, Eric W. Biederman <ebiederm@xmission.com=
> wrote:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>> On Sat, May 21, 2011 at 4:39 PM, Eric W. Biederman
>> <ebiederm@xmission.com> wrote:
>>> In a hopeless quest to avoid conflicts when merging a new system ca=
ll
>>> and wiring it up I have pulled in bits of net-next and the parisc t=
ree.
>>> You have already pulled the net-next bits. =C2=A0The parisc bits in=
 my tree
>>> are:
>>
>> Ok, this just means that I won't pull from you.
>
> Sure. =C2=A0I will try to be a little more patient and resend the pul=
l
> request after James has sent the pull request for the parisc tree.
> At which point the only unique changes in my tree will be mine.
>
>> It's that simple. We don't do this. Ever.
>
> Hah. I seem to remember bits of pulling from non-rebasing trees being=
 ok
> in well defined contexts. =C2=A0This seems like one. =C2=A0Especially=
 when you
> have checked with the maintainers.
>
> Plus all of the parisc bits in addition to being in the linux-next
> are trivially correct.
>
>> Why the hell did you even worry about wiring up parisc system calls?
>> That's not your job.
>
> Because in general it is the job of he who changes something to fix u=
p
> every possible place.
>
> Now maybe I went a little too far in trying to resolve the conflicts,
> but I did check with the David Miller and James Bottomley and they kn=
ew
> what I was doing.
>
> Quite honestly adding system calls is a mess that know one seems to
> know how to do right. =C2=A0So I flipped a coin and took a stab at it=
=2E

At first, I was delighted to see that somebody took care of adding
syscalls to the
non-popular architectures.

At second, I saw the conflicts in e.g. parisc and m68k due to this.

Hence now I think it's better to leave the wiring up to the
architecture maintainers, as
before.
I'm even thinking to suggest to first let go in the syscall (without
any wiring up, not
even on x86), and let all wiring up be handled afterwards. This would
enforce that
syscalls numbers are not cast in stone, until they hit mainline.

This does mean that scripts/checksyscalls.sh needs to be changed, as in=
itially
new syscalls aren't wired up there neither. The implementation of the
syscalls needs
to announce somehow that it's there and that it's a syscall.

What do you think?

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
