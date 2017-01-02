From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Mon, 2 Jan 2017 17:03:03 +0100
Message-ID: <20170102160303.GC3609@localhost.localdomain>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
 <CAFcVECLg-hXvfgwRW-fxi+N0k=7pTaEMhS5EMXV9_OO+xGRUqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rafal Ozieblo <rafalo@cadence.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.
To: Harini Katakam <harinikatakamlinux@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAFcVECLg-hXvfgwRW-fxi+N0k=7pTaEMhS5EMXV9_OO+xGRUqA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 02, 2017 at 05:13:34PM +0530, Harini Katakam wrote:
> From the revision history of Cadence spec, all versions starting
> r1p02 have ability to include timestamp in descriptors.

So why not add code to read the version, hm?

> For previous versions the event register is the only option.

And is it true that the regsiters do not latch the time stamp?

If so, then the IP core is more than useless.

Thanks,
Richard
