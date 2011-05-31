From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uts: Make default hostname configurable, rather than
 always using "(none)"
Date: Tue, 31 May 2011 12:46:30 -0700 (PDT)
Message-ID: <20110531.124630.449848946.davem@davemloft.net>
References: <20110530223847.GA29245@leaf>
	<BANLkTikgqkd0BckvTrFwAOmJQ0ObP4OOjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: josh@joshtriplett.org, netdev@vger.kernel.org, serge@hallyn.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	kel@otaku42.de, pkg-sysvinit-devel@lists.alioth.debian.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTikgqkd0BckvTrFwAOmJQ0ObP4OOjg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 May 2011 20:35:37 +0900

> On Tue, May 31, 2011 at 7:38 AM, Josh Triplett <josh@joshtriplett.org=
> wrote:
>>
>> The "hostname" tool falls back to setting the hostname to "localhost=
" if
>> /etc/hostname does not exist. =A0Distribution init scripts have the =
same
>> fallback. =A0However, if userspace never calls sethostname, such as =
when
>> booting with init=3D/bin/sh, or otherwise booting a minimal system w=
ithout
>> the usual init scripts, the default hostname of "(none)" remains,
>> unhelpfully appearing in various places such as prompts
>> ("root@(none):~#") and logs. =A0Furthermore, "(none)" doesn't typica=
lly
>> resolve to anything useful.
>=20
> Ok, I'm fine with this. So Ack as far as I'm concerned.
>=20
> Does this make most sense through the networking tree, or what?

Linus, you can just apply this directly.

Thanks!
