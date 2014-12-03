From: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Wed, 3 Dec 2014 05:38:27 +0000
Message-ID: <547EA1D1.8010202@audiocodes.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
 <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no>
 <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
 <alpine.LNX.2.03.1411271932510.1548@gmail.com> <87ppc71xne.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412012202480.1301@gmail.com>
 <B315C8AC-3B33-406B-A728-14F8FAAAE986@audiocodes.com>
 <547D37CA.7050506@audiocodes.com>
 <alpine.LNX.2.03.1412020729470.1351@gmail.com>
 <547D5F84.6020608@audiocodes.com>
 <alpine.LNX.2.03.1412020747360.1921@gmail.com>
 <547D6D7B.5090704@audiocodes.com>
 <E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
 <547D7243.80508@audiocodes.com>
 <alpine.LNX.2.03.1412021130410.2697@gmail.com> <87fvcyqoup.fsf@nemi.mork.no>
 <alpine.LNX.2.03.1412021410270.29633@gmail.com>
 <87lhmqp400.fsf@nemi.mork.no>,<alpine.LNX.2.03.1412021453340.7488@gmail.com>
 <1417532733483.89987@audiocodes.com>
 <alpine.LNX.2.03.1412021627360.8131@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Midge Shaojun Tan" <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.03.1412021627360.8131-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Content-Language: en-US
Content-ID: <EE3A94D0D4C8A74CB3AE3C7B427351F3-NhzUejbdEhGcE4WynfumptQqCkab/8FMAL8bYrjMMd8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

My dongle also works with the huawei driver. I think only the 32bit
format and NDP location matter. We may modify the TX function to put NT=
H
and NDP at the beginning of a NTB and see if it will work with the
driver cdc_ncm.

Regards,
Kevin

On 12/02/2014 11:28 PM, Enrico Mioso wrote:
> ... And what do you think about the source code of their ndis driver?
> We at least know now the device work with it, so we have something to=
 mimic :D
> thank you for your work and patience Kevin.
>
> On Tue, 2 Dec 2014, Kevin Zhu wrote:
>
> =3D=3DDate: Tue, 2 Dec 2014 16:04:25
> =3D=3DFrom: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
> =3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Bj=F8rn Mork <bjorn@mor=
k.no>
> =3D=3DCc: Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
> =3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
> =3D=3D    Midge Shaojun  Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
> =3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
> =3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
> =3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> =3D=3DSubject: Re: Is this 32-bit NCM?
> =3D=3D
> =3D=3DI do not understand why the wSequence matters. By the way, I th=
ink I see some NDPs are right after NTH headers in the windows capture.
> =3D=3D
> =3D=3D________________________________________
> =3D=3DFrom: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> =3D=3DSent: Tuesday, December 2, 2014 21:53
> =3D=3DTo: Bj=F8rn Mork
> =3D=3DCc: Kevin Zhu; Eli Britstein; Alex Strizhevsky; Midge Shaojun  =
Tan; youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TaqPxH82wqD4g@public.gmane.org=
g
> =3D=3DSubject: Re: Is this 32-bit NCM?
> =3D=3D
> =3D=3DThank you very much Bjorn.
> =3D=3D
> =3D=3D
> =3D=3DOn Tue, 2 Dec 2014, Bj=F8rn Mork wrote:
> =3D=3D
> =3D=3D=3D=3DDate: Tue, 2 Dec 2014 14:37:03
> =3D=3D=3D=3DFrom: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> =3D=3D=3D=3DTo: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> =3D=3D=3D=3DCc: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
> =3D=3D=3D=3D    Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
> =3D=3D=3D=3D    Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
> =3D=3D=3D=3D    Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
> =3D=3D=3D=3D    "youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
> =3D=3D=3D=3D    "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TaqPxH82wqD4g@public.gmane.org=
g>,
> =3D=3D=3D=3D    "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> =3D=3D=3D=3DSubject: Re: Is this 32-bit NCM?
> =3D=3D=3D=3D
> =3D=3D=3D=3DEnrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> =3D=3D=3D=3D
> =3D=3D=3D=3D> ... but out of curiosity: are NCM specs allowing to cha=
nge order of things in
> =3D=3D=3D=3D> the package or not?
> =3D=3D=3D=3D> This is not to start philosofical falames or something,=
 but to understand
> =3D=3D=3D=3D> better how things work. And, if they do: how much arbit=
rarily?
> =3D=3D=3D=3D
> =3D=3D=3D=3DOnly the NTB header has a fixed location. The rest can be=
 anywhere and
> =3D=3D=3D=3Din any order. Quoting from section 3 Data Transport:
> =3D=3D=3D=3D
> =3D=3D=3D=3D  "Within any given NTB, the NTH always must be first; bu=
t the other
> =3D=3D=3D=3D   items may occur in arbitrary order."
> =3D=3D=3D=3D
> =3D=3D=3D=3D
> =3D=3D=3D=3DBj=F8rn
> =3D=3D=3D=3D
> =3D=3DThis email and any files transmitted with it are confidential m=
aterial. They are intended solely for the use of the designated individ=
ual or entity to whom they are addressed. If the reader of this message=
 is not the intended recipient, you are hereby notified that any dissem=
ination, use, distribution or copying of this communication is strictly=
 prohibited and may be unlawful.
> =3D=3D
> =3D=3DIf you have received this email in error please immediately not=
ify the sender and delete or destroy any copy of this message
> =3D=3D
This email and any files transmitted with it are confidential material.=
 They are intended solely for the use of the designated individual or e=
ntity to whom they are addressed. If the reader of this message is not =
the intended recipient, you are hereby notified that any dissemination,=
 use, distribution or copying of this communication is strictly prohibi=
ted and may be unlawful.

If you have received this email in error please immediately notify the =
sender and delete or destroy any copy of this message
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
