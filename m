From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2 1/3] net: smc91x: isolate u16 writes alignment workaround
Date: Sun, 16 Oct 2016 12:05:19 +0200
Message-ID: <87k2d8623k.fsf@belgarion.home>
References: <1476559670-25056-1-git-send-email-robert.jarzmik@free.fr>
        <1476559670-25056-2-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Pitre <nico@fluxnic.net>,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: robert.jarzmik@free.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476559670-25056-2-git-send-email-robert.jarzmik@free.fr>
        (Robert Jarzmik's message of "Sat, 15 Oct 2016 21:27:48 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Jarzmik <robert.jarzmik@free.fr> writes:

> diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
> index ea8465467469..dff165ed106d 100644
> --- a/drivers/net/ethernet/smsc/smc91x.h
> +++ b/drivers/net/ethernet/smsc/smc91x.h

And there is also the specific case of ARCH=MN10300, where I didn't see :
#include <unit/smc91111.h>

In which SMC_outw() is also defined ... sic.

So this is also to be fixed, thanks to kbuild test robot.

--
Robert
