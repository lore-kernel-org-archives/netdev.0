From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Fri, 23 Oct 2009 16:39:07 +0200
Message-ID: <4AE1C00B.5010008@imap.cc>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>	 <20091021211906.GA11401@ami.dom.local>	 <1256160330.12174.2.camel@johannes.local>	 <20091021213947.GA12202@ami.dom.local> <1256200021.12174.11.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752142AbZJWOjJ@vger.kernel.org>
In-Reply-To: <1256200021.12174.11.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Johannes Berg schrieb:
> On Wed, 2009-10-21 at 23:39 +0200, Jarek Poplawski wrote:
>=20
>> I'm not sure I can understand your question. This patch is mainly to
>> avoid using netif_rx()/netif_rx_ni() pair as a test of proper proces=
s
>> context handling; IMHO there're better tools for this (lockdep,
>> WARN_ON's).
>=20
> I'm saying that it seems to me, as indicated by the API (and without
> proof otherwise that's how it is) the networking layer needs to have
> packets handed to it with softirqs disabled.

Strange. Then what are the two separate functions netif_rx() and
netif_rx_ni() for?

> This really should be obvious. You're fixing the warning at the sourc=
e
> of the warning, rather than the source of the problem.

Good idea. So please do tell us where the source of the problem is.

Thanks,
Tilman

- --
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFK4cALQ3+did9BuFsRAnW8AKCP4ey+gT2RZBYpzx91PaXd11A/PwCgh35g
fhEbJs++1BRIQ3encV8fIm4=3D
=3DSSaA
-----END PGP SIGNATURE-----
