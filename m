From: Andreas Schwab <schwab@suse.de>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 23:55:18 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <jevfj1nwe1.fsf@sykes.suse.de>
References: <20040512020700.6f6aa61f.akpm@osdl.org>
	<20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com>
	<20040512193349.GA14936@elte.hu>
	<Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
	<20040512200305.GA16078@elte.hu>
	<Pine.LNX.4.58.0405121400360.11950@bigblue.dev.mdolabs.com>
	<20040512213913.GA16658@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jgarzik@pobox.com>,
	Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262866AbUELV4J@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040512213913.GA16658@fieldses.org> (J. Bruce Fields's
 message of "Wed, 12 May 2004 17:39:13 -0400")
List-Id: netdev.vger.kernel.org

"J. Bruce Fields" <bfields@fieldses.org> writes:

> If gcc really optimizes that to just the identity function, then sure=
ly
> that's a gcc bug?  Multiplication is left-associative, so i * 1000 /
> 1000 =3D (i * 1000) / 1000, but (i * 1000) should be zero for any i
> divisible by i^(sizeof(int) - 12).

Signed integer overflow is undefined in C, so the compiler is allowed t=
o
assume it does not happen.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
