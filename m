From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 4/7] mfd: add MFD based flexcard driver
Date: Tue, 13 Aug 2013 10:55:08 +0100
Message-ID: <20130813095508.GA5109@lee--X1>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
 <1376384922-8519-6-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Holger Dengler <dengler@linutronix.de>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:50560 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594Ab3HMJzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:55:17 -0400
Received: by mail-ee0-f53.google.com with SMTP id b15so4103416eek.40
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 02:55:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1376384922-8519-6-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013, Benedikt Spranger wrote:

> This patch provides support for Eberp=C3=A4cher Flexcard. The Flexcar=
d comes
> with two PCI bars, one for the glue layer and one for the "IPs". The
> second bar may have multiple other devices like flexray or d_can
> devices. The driver utilites the MFD framework and creates various
> subdevices. Not only for the additional "IPs" but also for the clock
> source and clockevent provided by the card.
>=20
> Cc: Samuel Ortiz <sameo@linux.intel.com>
> Cc: Lee Jones <lee.jones@linaro.org>
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
> Signed-off-by: Holger Dengler <dengler@linutronix.de>
> ---
>  drivers/mfd/Kconfig           |   40 ++
>  drivers/mfd/Makefile          |    2 +
>  drivers/mfd/flexcard-core.c   | 1059 +++++++++++++++++++++++++++++++=
++++++++++
>  drivers/mfd/flexcard-dma.c    |  561 ++++++++++++++++++++++
>  drivers/mfd/flexcard-irq.c    |  333 +++++++++++++
>  drivers/mfd/flexcard.h        |    8 +
>  include/linux/eray.h          |  650 +++++++++++++++++++++++++
>  include/linux/flexcard.h      |   95 ++++
>  include/uapi/linux/Kbuild     |    2 +
>  include/uapi/linux/eray.h     |   34 ++
>  include/uapi/linux/flexcard.h |  429 +++++++++++++++++
>  11 files changed, 3213 insertions(+)
>  create mode 100644 drivers/mfd/flexcard-core.c
>  create mode 100644 drivers/mfd/flexcard-dma.c
>  create mode 100644 drivers/mfd/flexcard-irq.c
>  create mode 100644 drivers/mfd/flexcard.h
>  create mode 100644 include/linux/eray.h
>  create mode 100644 include/linux/flexcard.h
>  create mode 100644 include/uapi/linux/eray.h
>  create mode 100644 include/uapi/linux/flexcard.h

Wow, this is a huge patch which is going to be an insanely long,
laborious and complex task to review it all.

Can you split this up into many patches? Adding functionality
incrementally instead of rolling it up into this ball of wax?

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
