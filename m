From: Olaf Hering <olh@suse.de>
Subject: Re: consistent ioctl for getting all net interfaces?
Date: Sun, 30 May 2004 22:25:08 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040530202508.GA31468@suse.de>
References: <pan.2004.05.23.04.28.28.143054@triplehelix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264301AbUE3U16@vger.kernel.org>
To: Joshua Kwan <joshk@triplehelix.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <pan.2004.05.23.04.28.28.143054@triplehelix.org>
List-Id: netdev.vger.kernel.org

 On Sat, May 22, Joshua Kwan wrote:

> Hi,
>=20
> I'm interested in not having to parse /proc/net/dev to get a list of =
all
> available (not necessarily even up) interfaces on the system. I
> investigated the ioctl SIOCGIFCONF, but it seems to behave differentl=
y on
> 2.4 and 2.6 series kernels, e.g. sometimes it won't return all interf=
aces.

you should bring that to netdev@oss.sgi.com instead of lkml.

IF the ioctl has really changed, then it would be a bug. I just played
with ipconfig from the klibc distribution, and it returns only
interfaces in UP state. I'm sure that ipconfig binary worked when the
code was written.

If the ioctl is supposed to work how it does in 2.6, there is still
/sys/class/net/*. Thats (probably) more reliable than a text parser.
See `nameif -r 'foo: bar' eth0` as example.


--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
