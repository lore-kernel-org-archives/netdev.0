From: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 13:22:37 +0000
Message-ID: <CAGiyFddB_HT3H2yhYQ5rprYZ487rJ4iCaH9uPJQD57hiPbn9ng@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
 <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a114022ca613f570543c67763
Cc: George Spelvin <linux@sciencehorizons.net>, Andi Kleen <ak@linux.intel.com>,
	David Miller <davem@davemloft.net>, David Laight <David.Laight@aculab.com>,
	Eric Biggers <ebiggers3@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>,
	kernel-hardening@lists.openwall.com,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@amacapital.net>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>, Linus Torvalds <torvalds@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>, vegard.nossum@gmail.com,
	"Daniel J . Bernstein" <djb@cr.yp.to>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <kernel-hardening-return-5634-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
List-Id: netdev.vger.kernel.org

--001a114022ca613f570543c67763
Content-Type: text/plain; charset=UTF-8

It needs some basic security review, which I'll try do next week (check for
security margin, optimality of rotation counts, etc.). But after a lot of
experience with this kind of construction (BLAKE, SipHash, NORX), I'm
confident it will be safe as it is.



On Fri, Dec 16, 2016 at 1:44 PM Jason A. Donenfeld <Jason@zx2c4.com> wrote:

> Hey JP,
>
> On Fri, Dec 16, 2016 at 9:08 AM, Jean-Philippe Aumasson
> <jeanphilippe.aumasson@gmail.com> wrote:
> > Here's a tentative HalfSipHash:
> > https://github.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c
> >
> > Haven't computed the cycle count nor measured its speed.
>
> This is incredible. Really. Wow!
>
> I'll integrate this into my patchset and will write up some
> documentation about when one should be used over the other.
>
> Thanks again. Quite exciting.
>
> Jason
>

--001a114022ca613f570543c67763
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">It needs some basic security review, which I&#39;ll try do=
 next week (check for security margin, optimality of rotation counts, etc.)=
. But after a lot of experience with this kind of construction (BLAKE, SipH=
ash, NORX), I&#39;m confident it will be safe as it is.<div><br></div><div>=
<br></div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr">On Fri, Dec=
 16, 2016 at 1:44 PM Jason A. Donenfeld &lt;<a href=3D"mailto:Jason@zx2c4.c=
om">Jason@zx2c4.com</a>&gt; wrote:<br></div><blockquote class=3D"gmail_quot=
e" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">=
Hey JP,<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
On Fri, Dec 16, 2016 at 9:08 AM, Jean-Philippe Aumasson<br class=3D"gmail_m=
sg">
&lt;<a href=3D"mailto:jeanphilippe.aumasson@gmail.com" class=3D"gmail_msg" =
target=3D"_blank">jeanphilippe.aumasson@gmail.com</a>&gt; wrote:<br class=
=3D"gmail_msg">
&gt; Here&#39;s a tentative HalfSipHash:<br class=3D"gmail_msg">
&gt; <a href=3D"https://github.com/veorq/SipHash/blob/halfsiphash/halfsipha=
sh.c" rel=3D"noreferrer" class=3D"gmail_msg" target=3D"_blank">https://gith=
ub.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c</a><br class=3D"gmail_m=
sg">
&gt;<br class=3D"gmail_msg">
&gt; Haven&#39;t computed the cycle count nor measured its speed.<br class=
=3D"gmail_msg">
<br class=3D"gmail_msg">
This is incredible. Really. Wow!<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
I&#39;ll integrate this into my patchset and will write up some<br class=3D=
"gmail_msg">
documentation about when one should be used over the other.<br class=3D"gma=
il_msg">
<br class=3D"gmail_msg">
Thanks again. Quite exciting.<br class=3D"gmail_msg">
<br class=3D"gmail_msg">
Jason<br class=3D"gmail_msg">
</blockquote></div>

--001a114022ca613f570543c67763--
