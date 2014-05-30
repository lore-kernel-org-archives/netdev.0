From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next 5/7] net:fec: add support for dumping transmit
	ring on timeout
Date: Fri, 30 May 2014 01:03:36 +0100
Message-ID: <20140530000336.GM3693@n2100.arm.linux.org.uk>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com> <1398773350-7293-5-git-send-email-Frank.Li@freescale.com> <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com> <CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com> <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F70156E@AcuExch.aculab.com> <20140429143828.GB26756@n2100.arm.linux.org.uk> <51ca1e44e5e849ecbae40bf0beaa2028@BY2PR03MB377.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
	'Frank Li' <lznuaa@gmail.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:38757 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751538AbaE3AFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 20:05:15 -0400
Content-Disposition: inline
In-Reply-To: <51ca1e44e5e849ecbae40bf0beaa2028@BY2PR03MB377.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 08:17:07AM +0000, fugang.duan@freescale.com wrote:
> Hi, Russell,
> 
> I see linux next and net "imx_v6_v7_defconfig" don't enable "CONFIG_CMA",
> if you enable the feature,

Sorry, telling people that CMA is required to avoid that is just not an
acceptable "solution".

With CMA not enabled, the DMA memory provided to the driver is still
perfectly valid and should be no different from what CMA provides.

I'd strongly suggest investigating why there is this difference, and
what the difference is - I'd assume freescale have the ability to do
that with their own devices much more than I have, and probably to a
greater depth too - especially as there is no possibility what so ever
of using any kind of hardware debug on the iMX6 platforms I have.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
