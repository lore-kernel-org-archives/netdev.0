From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH 2/2] Documentation: devictree: Add macb mdio bindings
Date: Mon, 5 Dec 2016 11:23:25 +0100
Message-ID: <b29b10b5-e31f-6fa2-c27d-583402eee84d@atmel.com>
References: <1480326567-6132-1-git-send-email-harinik@xilinx.com>
 <20161203213553.f3agwvaseufglnq6@rob-hp-laptop>
 <CAFcVECJRbgAxQMbu7jABHjkiicD1Ysp7WmDMoUzs2P5qn26uqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Harini Katakam <harini.katakam@xilinx.com>,
        David Miller <davem@davemloft.net>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        "ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
        Kumar Gala <galak@codeaurora.org>,
        "Boris Brezillon" <boris.brezillon@free-electrons.com>,
        <alexandre.belloni@free-electrons.com>, <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "michals@xilinx.com" <michals@xilinx.com>
To: Harini Katakam <harinikatakamlinux@gmail.com>,
        Rob Herring <robh@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFcVECJRbgAxQMbu7jABHjkiicD1Ysp7WmDMoUzs2P5qn26uqw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/12/2016 à 03:55, Harini Katakam a écrit :
> Hi Rob,
> 
> 
> Thanks for the review.
> On Sun, Dec 4, 2016 at 3:05 AM, Rob Herring <robh@kernel.org> wrote:
>> On Mon, Nov 28, 2016 at 03:19:27PM +0530, Harini Katakam wrote:
> <snip>
>>> +Required properties:
>>> +- compatible: Should be "cdns,macb-mdio"
>>
>> Only one version ever? This needs more specific compatible strings.
>>
> 
> This is part of the Cadence MAC in a way.
> I can use revision number from the Cadence spec I was working with.
> But it is not necessarily specific that version.

Yes it is:
you must specify the first precise SoC needing/implementing it:
"cdns,zynqmp-gem-mdio" or "xlnx,zynq-gem-mdio" or anything looking like
this.
So, if an Atmel implementation is slightly different, we can still use
our own "atmel,sama5d2-gem-mdio" or "cdns,sama5d2-gem-mdio"
compatibility string.
On the other hand, if it's strictly the same, we can use the
"xlnx,zynq-gem-mdio" compatibility without any problem...

> I'll take care of the other comments in the next version.
> 
> Regards,
> Harini
> 


-- 
Nicolas Ferre
