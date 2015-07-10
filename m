From: Stas Sergeev <stsp-cmBhpYW9OiY@public.gmane.org>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Fri, 10 Jul 2015 14:20:17 +0300
Message-ID: <559FAA71.2030209@list.ru>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru> <559EBC59.6020003@gmail.com> <559EDD0C.7020907@list.ru> <559EE45C.4040408@gmail.com> <559EEAE9.4000806@list.ru> <alpine.LNX.2.02.1507100940530.15010@sbrk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
	Stas Sergeev <stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Sebastien Rannou <mxs-i6rsG8ix9II@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.02.1507100940530.15010-i6rsG8ix9II@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

10.07.2015 11:46, Sebastien Rannou =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, 10 Jul 2015, Stas Sergeev wrote:
>=20
>> 10.07.2015 00:15, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Then, if the in-band status indication is not reliable (which reall=
y
>>> should be completely understood),
>> Agree!
>> But this is not something I can help with.
>> Sebastien Rannou reports the problem, please ask him whatever
>> you see fits to get a better understanding of a problem.
>> The fact that his HW does not generate the inband status, is
>> _my own guess_.
>=20
> Yes, I confirm that my HW does not generate an in-band status. AFAIK,=
 it's
> a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY =
(with
> inband status) is connected to the switch through QSGMII, and in this=
 context
> we are on the media side of the PHY.
Hmm, interesting.
So if I parse the above correctly, you have something like 88E1340S set
up into a mode when SGMII is used as media interface and QSGMII as syst=
em
interface (terms are from datasheet page 5), then you connect the media
interface to armada-xp and system interface to the switch.

I wonder if it is the right thing to do.
AFAIK you could as well set up armada-xp into QSGMII mode and connect
that to switch. The driver would then disable the use of inband status
and everything would be fine.
Either way, your use-case proves that only DT can decide the use of an
inband status.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
