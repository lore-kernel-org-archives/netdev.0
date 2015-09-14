From: Harini Katakam <harinikatakamlinux@gmail.com>
Subject: Re: [RFC PATCH 3/3] devicetree: macb: Add optional property tsu-clk
Date: Mon, 14 Sep 2015 23:04:42 +0530
Message-ID: <CAFcVEC+KKhJFW5X2ff5ZY3Tp8LRQ-8=T7X7NJ2bBL7c822KYhw@mail.gmail.com>
References: <1441958258-35441-1-git-send-email-harinik@xilinx.com>
	<1441958258-35441-4-git-send-email-harinik@xilinx.com>
	<20150911165256.GT19678@xsjsorenbubuntu>
	<CAFcVECK=EONgqPq1jt_kti-VKXPWGVj3OSnqUvo0YcR65Z+Phg@mail.gmail.com>
	<20150914095846.0d8e2d74@bbrezillon>
	<20150914144423.GG19678@xsjsorenbubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Boris Brezillon <boris.brezillon@free-electrons.com>,
	Harini Katakam <harini.katakam@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	alexandre.belloni@free-electrons.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	"michals@xilinx.com" <michals@xilinx.com>, anirudh@xilinx.com
To: =?UTF-8?Q?S=C3=B6ren_Brinkmann?= <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150914144423.GG19678@xsjsorenbubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Soren/Boris,

On Mon, Sep 14, 2015 at 8:14 PM, S=C3=B6ren Brinkmann
<soren.brinkmann@xilinx.com> wrote:
> On Mon, 2015-09-14 at 09:58AM +0200, Boris Brezillon wrote:
>> Hi Harini,
>>
>> On Mon, 14 Sep 2015 09:39:05 +0530
>> Harini Katakam <harinikatakamlinux@gmail.com> wrote:
>>
>> > On Fri, Sep 11, 2015 at 10:22 PM, S=C3=B6ren Brinkmann
>> > <soren.brinkmann@xilinx.com> wrote:
>> > > Hi Harini,
>> > >
>> > > On Fri, 2015-09-11 at 01:27PM +0530, Harini Katakam wrote:
>> > >> Add TSU clock frequency to be used for 1588 support in macb dri=
ver.
>> > >>
>> > >> Signed-off-by: Harini Katakam <harinik@xilinx.com>
>> > >> ---
>> > >>  Documentation/devicetree/bindings/net/macb.txt |    3 +++
>> > >>  1 file changed, 3 insertions(+)
>> > >>
>> > >> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/D=
ocumentation/devicetree/bindings/net/macb.txt
>> > >> index b5d7976..f7c0ea8 100644
>> > >> --- a/Documentation/devicetree/bindings/net/macb.txt
>> > >> +++ b/Documentation/devicetree/bindings/net/macb.txt
>> > >> @@ -19,6 +19,9 @@ Required properties:
>> > >>       Optional elements: 'tx_clk'
>> > >>  - clocks: Phandles to input clocks.
>> > >>
>> > >> +Optional properties:
>> > >> +- tsu-clk: Time stamp unit clock frequency used.
>> > >
>> > > Why are we not using the CCF and a clk_get_rate() in the driver?
>> > >
>> >
>> > If the clock source was only internal, we could use this
>> > approach as usual. But TSU clock can be configured to
>> > come from an external clock source or internal.
>>
>> How about declaring a fixed-rate clk [1] if it comes from an externa=
l
>> clk, and using a clk driver for the internal clk case?
>> This way you'll be able to use the clk API (including the
>> clk_get_rate() function) instead of introducing a new way to retriev=
e a
>> clk frequency.
>
> Right. Also, Zynq does already support external clock inputs (actuall=
y,
> every clock originates from some external clock/oscillator at some
> point). Maybe that code needs some additions to handle the TSU clock
> too. But either way, I can't see why a clock cannot be modeled using =
the
> CCF.

Ok, I'm going to try this.

Regards,
Harini
