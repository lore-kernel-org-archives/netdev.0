From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 1/3] bnx2x: remove TPA_ENABLE_FLAG
Date: Thu, 1 Sep 2011 03:52:34 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097B04C@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1314802836-9862-1-git-send-email-mschmidt@redhat.com>
 <1314802836-9862-2-git-send-email-mschmidt@redhat.com>
 <201108311816.30468.vladz@broadcom.com> <20110831175849.328192b8@alice>
 <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097ADE0@SJEXCHCCR02.corp.ad.broadcom.com>
 <CAHXqBF+f=3yM88CJ+FpNELBb+Sof5q1=pTXm303-QN7y6M9Dsg@mail.gmail.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AAD01067097B03C@SJEXCHCCR02.corp.ad.broadcom.com>
 <CAHXqBFJR=5zTZeq+HnfRp2rb9yX3L=Kjwi_1AyWU2EDqZ=gCWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michal Schmidt" <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3694 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832Ab1IAKws convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 06:52:48 -0400
In-Reply-To: <CAHXqBFJR=5zTZeq+HnfRp2rb9yX3L=Kjwi_1AyWU2EDqZ=gCWQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If I understand correctly, bnx2x_reload_if_running() failure does not
> mean exactly that features change failed. It means that device failed
> to initialize, possibly because of other (transient?) conditions. So
> unless reverting features change and retrying the initialization is
> known to allow the device to be brought back,=20

In a general case u can't be sure which (if at all) features change cau=
sed
the failure. So, u should return the configuration to the last known "g=
ood" one.

> there's no difference
> whether old or new dev->features value is kept and which set is
> reported by ethtool.

Well, I disagree with u on this one - I think that if the state change =
operation
(of any object, in our case it's a netdev) fails, the current state sho=
uld remain unchanged.

Thanks,
vlad

>=20
> Best Regards,
> Micha=B3 Miros=B3aw
