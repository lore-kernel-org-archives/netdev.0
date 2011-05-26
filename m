From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: linux-next: Tree for May 26 (drivers/net/caif)
Date: Thu, 26 May 2011 23:15:34 +0200
Message-ID: <BANLkTikik8+f1D4D_Dv_rFK=QQjdce9rwg@mail.gmail.com>
References: <20110526163941.7dfcad1a.sfr@canb.auug.org.au>
	<20110526120702.fac24de0.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, gregkh@suse.de
To: Randy Dunlap <randy.dunlap@oracle.com>, balbi@ti.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110526120702.fac24de0.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Randy,

[Randy]
> (not new)
>
> drivers/net/caif/caif_serial.c:194: warning: 'return' with no value, =
in function returning non-void
> drivers/net/caif/caif_serial.c:202: warning: 'return' with no value, =
in function returning non-void
>
>
> I'm curious: =C2=A0how do warnings like this get overlooked?
> too much noise in the build messages? =C2=A0or it wasn't overlooked, =
just ignored?

The patch introducing this problem is "tty: make receive_buf()
return the amout of bytes received" by Felipe Balbi <balbi@ti.com>.
It seems that this patch has been posted to linux-serial and not to
the netdev list or the gits net-next-2.6 or net-2.6 that I follow.
It's probably no excuse, but this problem is news to me.

Should I post a patch on linux-next anyway for this issue?

Regards,
Sjur
