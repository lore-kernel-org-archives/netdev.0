From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Wed, 25 May 2011 17:22:39 +0200
Message-ID: <BANLkTinPJSJrr2LPVyCt_7ci7pSu-sDdRQ@mail.gmail.com>
References: <m1boyvpo9r.fsf@fess.ebiederm.org>
	<1306048393.4092.8.camel@mulgrave.site>
	<20110522084224.GA12279@elte.hu>
	<m1k4dgr35i.fsf@fess.ebiederm.org>
	<20110524071628.GA31612@elte.hu>
	<4508.1306283693@localhost>
	<20110525082514.GE21552@elte.hu>
	<BANLkTikVDrU7Nx6143gPuB=1vwqkMFiRiQ@mail.gmail.com>
	<20110525124741.GC29300@elte.hu>
	<BANLkTimQcyX9XSY__9Bpg3tg7-P7gtOTkw@mail.gmail.com>
	<20110525131746.GA19118@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110525131746.GA19118@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 25, 2011 at 15:17, Ingo Molnar <mingo@elte.hu> wrote:
> * Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> On Wed, May 25, 2011 at 14:47, Ingo Molnar <mingo@elte.hu> wrote:
>> > * Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> >
>> >> > But at least the primary, 'native' syscall table of every arch
>> >> > could be kept rather fresh via generic enumeration.
>> >>
>> >> So we can start all over at offset 501 (alpha just started using
>> >> 500) with a unified, clean, and compressed list of syscalls? Or d=
o
>> >> we have some more other-os-compat syscalls around in this range?
>> >
>> > No, that would leave a big hole in the syscall table of most
>> > architectures.
>>
>> Sure, but we could (a) optimize for the case where the syscall numbe=
r is
>> larger than 500 and/or (b) drop support for syscall numbers smaller =
than
>> 501, depending on a config option.
>
> Dunno why there is so much desire to complicate and break
> well-working ABIs while we have a 14+ MLOC kernel with so much code
> in it that is in dire need to be improved! :-)

Because we (think we) need less active brain cells to write emails that=
 to code.
So when we're not "active" enough to hack, we tend to respond to long w=
inding
getting off-topic email threads...

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
