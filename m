From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Mon, 2 Jan 2017 15:47:07 +0100
Message-ID: <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "harinikatakamlinux@gmail.com" <harinikatakamlinux@gmail.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>
To: Richard Cochran <richardcochran@gmail.com>,
        Rafal Ozieblo <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102113155.GA16373@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/01/2017 à 12:31, Richard Cochran a écrit :
> On Mon, Jan 02, 2017 at 09:36:10AM +0000, Rafal Ozieblo wrote:
>> According Cadence Hardware team:
>> "It is just that some customers prefer to have the time in the descriptors as that is provided per frame.
>> The registers are simply overwritten when a new event frame is transmitted/received and so software could miss it."
>> The question is are you sure that you read timestamp for current frame? (not for the next frame).
> 
> AFAICT, having the time stamp in the descriptor is not universally
> supported.  Looking at the Xilinx Zynq 7000 TRM, I can't find any
> mention of this.

This is why I proposed to address options incrementally: without
timestamp support in descriptor (this patch series), then adding this
feature in another patch series.

Rafal, this is why Andrei noted that the case covered by this series is
not adapted to GEM-GXL and doesn't address the "timestamp in descriptor"
case.

> This Cadence IP core is a complete disaster.

Well, it evolved and propose several options to different SoC
integrators. This is not something unusual...
I suspect as well that some other network adapters have the same
weakness concerning PTP timestamp in single register as the early
revisions of this IP.

> Unless someone can tell us how this IP works in all of its
> incarnations, this series is going nowhere.

We're already as v4 (thanks to your fruitful contributions BTW) for this
series and will try to add features for other IP options & revisions
incrementally.
I suspect that Rafal tend to jump too quickly to the latest IP revisions
and add more options to this series: let's not try to pour too much
things into this code right now.

FYI, Andrei will be back online next week.

Regards,
-- 
Nicolas Ferre
