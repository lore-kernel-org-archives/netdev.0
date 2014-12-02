From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Tue, 02 Dec 2014 14:37:03 +0100
Message-ID: <87lhmqp400.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<87ppc957h1.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1411271037050.9464@gmail.com>
	<874mtl55ar.fsf@nemi.mork.no>
	<CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
	<alpine.LNX.2.03.1411271932510.1548@gmail.com>
	<87ppc71xne.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412012202480.1301@gmail.com>
	<B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
	<547D37CA.7050506@audiocodes.com>
	<alpine.LNX.2.03.1412020729470.1351@gmail.com>
	<547D5F84.6020608@audiocodes.com>
	<alpine.LNX.2.03.1412020747360.1921@gmail.com>
	<547D6D7B.5090704@audiocodes.com>
	<E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
	<547D7243.80508@audiocodes.com>
	<alpine.LNX.2.03.1412021130410.2697@gmail.com>
	<87fvcyqoup.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412021410270.29633@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux\@gmail.com" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb\@vger.kernel.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1412021410270.29633-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Enrico Mioso's
	message of "Tue, 2 Dec 2014 14:11:47 +0100 (CET)")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> ... but out of curiosity: are NCM specs allowing to change order of t=
hings in=20
> the package or not?
> This is not to start philosofical falames or something, but to unders=
tand=20
> better how things work. And, if they do: how much arbitrarily?

Only the NTB header has a fixed location. The rest can be anywhere and
in any order. Quoting from section 3 Data Transport:

  "Within any given NTB, the NTH always must be first; but the other
   items may occur in arbitrary order."


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
