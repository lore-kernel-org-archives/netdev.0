From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] uts: Make default hostname configurable, rather than
 always using "(none)"
Date: Tue, 31 May 2011 20:35:37 +0900
Message-ID: <BANLkTikgqkd0BckvTrFwAOmJQ0ObP4OOjg@mail.gmail.com>
References: <20110530223847.GA29245@leaf>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Kel Modderman <kel@otaku42.de>,
	pkg-sysvinit-devel@lists.alioth.debian.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110530223847.GA29245@leaf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2011 at 7:38 AM, Josh Triplett <josh@joshtriplett.org> =
wrote:
>
> The "hostname" tool falls back to setting the hostname to "localhost"=
 if
> /etc/hostname does not exist. =A0Distribution init scripts have the s=
ame
> fallback. =A0However, if userspace never calls sethostname, such as w=
hen
> booting with init=3D/bin/sh, or otherwise booting a minimal system wi=
thout
> the usual init scripts, the default hostname of "(none)" remains,
> unhelpfully appearing in various places such as prompts
> ("root@(none):~#") and logs. =A0Furthermore, "(none)" doesn't typical=
ly
> resolve to anything useful.

Ok, I'm fine with this. So Ack as far as I'm concerned.

Does this make most sense through the networking tree, or what?

              Linus
