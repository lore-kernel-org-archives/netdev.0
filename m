From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Sat, 21 May 2011 17:33:36 -0700
Message-ID: <m1boyvpo9r.fsf@fess.ebiederm.org>
References: <m11uzrvd26.fsf@fess.ebiederm.org>
	<BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTim4q5dK6nOb=pVKbk1c8b-Nh_hBfA@mail.gmail.com> (Linus
	Torvalds's message of "Sat, 21 May 2011 16:42:46 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Sat, May 21, 2011 at 4:39 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>>
>> In a hopeless quest to avoid conflicts when merging a new system cal=
l
>> and wiring it up I have pulled in bits of net-next and the parisc tr=
ee.
>> You have already pulled the net-next bits. =C2=A0The parisc bits in =
my tree
>> are:
>
> Ok, this just means that I won't pull from you.

Sure.  I will try to be a little more patient and resend the pull
request after James has sent the pull request for the parisc tree.
At which point the only unique changes in my tree will be mine.

> It's that simple. We don't do this. Ever.

Hah. I seem to remember bits of pulling from non-rebasing trees being o=
k
in well defined contexts.  This seems like one.  Especially when you
have checked with the maintainers.

Plus all of the parisc bits in addition to being in the linux-next
are trivially correct.

> Why the hell did you even worry about wiring up parisc system calls?
> That's not your job.

Because in general it is the job of he who changes something to fix up
every possible place.

Now maybe I went a little too far in trying to resolve the conflicts,
but I did check with the David Miller and James Bottomley and they knew
what I was doing.

Quite honestly adding system calls is a mess that know one seems to
know how to do right.  So I flipped a coin and took a stab at it.

Eric
