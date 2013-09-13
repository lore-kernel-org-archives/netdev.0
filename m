From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 4/7] ptp: switch to use gpiolib
Date: Fri, 13 Sep 2013 19:36:20 +0200
Message-ID: <m3r4csr5d7.fsf@intrepid.localdomain>
References: <1378816260-8091-1-git-send-email-linus.walleij@linaro.org>
	<20130910141912.GB5088@netboy>
	<CACRpkdZOCkLmgQHZSiqQfvLp=WzNsaE5AcY3siJ0b=bL0Xv8Pg@mail.gmail.com>
	<m38uz0vrlz.fsf@intrepid.localdomain>
	<20130913133659.GA11394@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Walleij <linus.walleij@linaro.org>,
	"linux-gpio\@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Imre Kaloz <kaloz@openwrt.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:36477 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751733Ab3IMRgY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 13:36:24 -0400
In-Reply-To: <20130913133659.GA11394@localhost.localdomain> (Richard Cochran's
	message of "Fri, 13 Sep 2013 15:36:59 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran <richardcochran@gmail.com> writes:

> I was really talking about the IXP465 with its PTP function. The Inte=
l
> devel board had a silicon bug making the PTP function useless. But
> even if the bug got fixed, still the PTP function was very limiting.
>
> I never got any feedback about the IXP465 PTP stuff, and so I doubt
> whether anyone is really using the Linux PTP driver on the IXP465, bu=
t
> you never know.

Ah, OK.
I have just checked, Intel's spec update says IXP46x steppings A1 and A=
2
are fixed. PTP on 46x-A0 is broken.
42x and 43x don't support PTP.

OTOH there is interesting stuff there:
Problem: The A-0 and A-1 stepping of the Intel=C2=AE IXP45X/IXP46X Prod=
uct Line of Network
         Processors can enter a condition whereby the system locks up w=
hen certain
         combinations of memory accesses occur nearly simultaneously.

         After more extensive investigation, it has been identified tha=
t the lockup condition can
         be caused by near-simultaneous accesses to 1 or 2 cache lines.=
 The accesses to the
         cache lines must be performed by the Intel XScale processor, S=
outh AHB, and/or North
         AHB for the lockup to happen.

Hmmm...
--=20
Krzysztof Halasa
