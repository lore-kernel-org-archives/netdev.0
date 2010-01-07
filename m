From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] lib/vsprintf.c: Add %pMF to format FDDI bit reversed
 MAC  addresses
Date: Thu, 07 Jan 2010 13:36:15 -0800
Message-ID: <1262900175.10429.75.camel@Joe-Laptop.home>
References: <BD79186B4FD85F4B8E60E381CAEE19090208954A@mi8nycmail19.Mi8.com>
	 <1262888625.10429.23.camel@Joe-Laptop.home>
	 <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: H Hartley Sweeten <hartleys@visionengravers.com>,
	David Miller <davem@davemloft.net>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1625 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751799Ab0AGVgR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 16:36:17 -0500
In-Reply-To: <e2d7436a1001071318l75750b29uece2a61884538d5b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-07 at 22:18 +0100, Micha=C5=82 Miros=C5=82aw wrote:=20
> Something like the following might be smaller and faster - no
> functions and their calls
> int rev =3D (fmt[1] =3D=3D 'F');
> p =3D pack_hex_byte(p, rev ? bitrev8(addr[i]) : addr[i]);

Right, better.  Just 6 bytes (x86).  Resubmitting.


