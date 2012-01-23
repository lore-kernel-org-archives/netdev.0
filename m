From: Mihai =?UTF-8?B?RG9uyJt1?= <mihai.dontu@gmail.com>
Subject: Re: [Bug 40422] New: 3.0: kernel panic - not syncing: fatal
 exception in interrupt
Date: Mon, 23 Jan 2012 16:53:58 +0200
Message-ID: <20120123165358.60b1ba11@mdontu-l.dsd.ro>
References: <bug-40422-27@https.bugzilla.kernel.org/>
	<20110801140418.510c5dc4.akpm@linux-foundation.org>
	<20110802004558.393e2a77@mdontu-dell>
	<20110803045916.363b35fb@mdontu-dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110803045916.363b35fb@mdontu-dell>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 3 Aug 2011 04:59:16 +0300 Mihai Don=C8=9Bu wrote:
> On Tuesday 02 August 2011 00:45:58 Mihai Don=C8=9Bu wrote:
> > > drat, the first part of that crash scrolled off the screen or
> > > wasn't in the photo.  I don't suppose it's possible to get that
> > > information?
> >=20
> > No, I'm afraid not. I'll disable the framebuffer decorations for th=
e
> > future. Should get me 4 or 5 more lines of backtrace when the crash
> > reappears.
> >=20
> > > Still, the oops is in netfilter code - a bad pointer dereference
> > > under devinet_ioctl->masq_device_event.
>=20
> I got another kernel panic, but it's in a different place and I've
> somehow managed to take a crappy snapshot (missing some of the right
> side info). Anyway, at the rate these tend to happen, I'm likely to b=
e
> able to submit a correct one pretty soon.
>=20
> Is there any option you'll like me to turn on?
>=20

This issue has not reproduced for me in quite some time, also I have
updated my hardware a month ago, so I'm likely unable to test any fixes
in this area.

The strange thing however is that for a while I suffered from a
"desynchronization" between "hard locked" and "soft locked" (as
displayed by rfkill) and I had to manually run rfkill to enable WiFi.
After that last kernel panic, things got back to normal. :-) But I
assume that was a hardware issue ...

You can probably close this bug.

Thanks,

--=20
Mihai Don=C8=9Bu
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
