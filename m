From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [NET] 64 bit byte counter for 2.6.3
Date: Wed, 18 Feb 2004 10:17:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218101711.25dda791@dell_ss3.pdx.osdl.net>
References: <1077123078.9223.7.camel@midux>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Markus =?ISO-8859-1?Q?H=E4stbacka?= <midian@ihme.org>
In-Reply-To: <1077123078.9223.7.camel@midux>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Feb 2004 18:51:19 +0200
Markus H=E4stbacka <midian@ihme.org> wrote:

> Ok, Here's a patch for 64 bit byte counters for 2.6.3. For any intreste=
d
> users to try.
>=20
> That means in english that the limit for RX bytes and TX bytes (in
> ifconfig for example) is much higher than the old 4GB limit on 32 bit
> systems.
>=20
> Orginal patch by Miika Pekkarinen, ported forward from 2.5 by me.
>=20
> Patch says 2.6.3-rc1, but patches cleanly on 2.6.3.
>=20
>         Markus

Some quick comments:
 * Network changes gets discussed on netdev@oss.sgi.com=20
 * 64 bit values are not atomic on 32 bit architectures=20
 * wider values in /proc output risks breaking apps like ifconfig and net=
stat
