From: David Miller <davem@davemloft.net>
Subject: Re: 'rmmod -f ipv6': BUG: unable to handle kernel paging request
Date: Thu, 04 Jul 2013 14:29:51 -0700 (PDT)
Message-ID: <20130704.142951.1908678475285188106.davem@davemloft.net>
References: <20130704210434.GA6381@Linus-Debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: linus.luessing@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130704210434.GA6381@Linus-Debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus L=FCssing <linus.luessing@web.de>
Date: Thu, 4 Jul 2013 23:04:34 +0200

> When trying to perform a forceful unload of an ipv6 kernel module
> on a 3.10 kernel then I'm getting a kernel panic with the attached
> trace.
>=20
> Is this supposed to happen due to the '-f' option or is this a bug
> in the ipv6 code?

The ipv6 module is not capable of being unloaded, sorry.

By using "-f" you are taking your own risk in the matter.
