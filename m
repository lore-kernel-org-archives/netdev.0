From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: tcp vulnerability?  haven't seen anything on it here...
Date: Wed, 21 Apr 2004 19:03:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040421170340.GB24201@wohnheim.fh-wedel.de>
References: <40869267.30408@nortelnetworks.com> <Pine.LNX.4.53.0404211153550.1169@chaos> <4086A077.2000705@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <4086A077.2000705@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 21 April 2004 12:25:27 -0400, Chris Friesen wrote:
>=20
> The impression I got was that some equipment was much more vulnerable=20
> due to having a) massive windows, and b) using sequential source ports,=
=20
> making it much easier to guess even if you can't tap the line.

Heise.de made it appear, as if the only news was that with tcp
windows, the propability of guessing the right sequence number is not
1:2^32 but something smaller.  They said that 64k packets would be
enough, so guess what the window will be.

Obvious solution would be to use a small window, which would cost
performance.  Different solution would be to use a different window
size for reset, like, say, 1.  Not sure if that would still be
standard, though.

J=F6rn

--=20
The cost of changing business rules is much more expensive for software
than for a secretaty.
-- unknown
