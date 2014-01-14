From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] dts: Add a binding for Synopsys emac max-frame-size
Date: Tue, 14 Jan 2014 10:30:59 -0600
Message-ID: <CAOwfj2NFCVU7+Gas-9cFf-18oaD=4DjDoYc83Dte=1QAo=GKug@mail.gmail.com>
References: <1389710409-14106-1-git-send-email-vbridgers2013@gmail.com>
	<1389710409-14106-2-git-send-email-vbridgers2013@gmail.com>
	<1389715056.10673.9.camel@linux-builds1>
	<1890114.hPeOerbe4b@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dinh Nguyen <dinguyen@altera.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, Kumar Gala <galak@codeaurora.org>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:46543 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbaANQbA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 11:31:00 -0500
In-Reply-To: <1890114.hPeOerbe4b@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll address comments and resubmit.

Vince

On Tue, Jan 14, 2014 at 10:07 AM, Florian Fainelli <f.fainelli@gmail.co=
m> wrote:
> Le mardi 14 janvier 2014, 09:57:36 Dinh Nguyen a =E9crit :
>> On Tue, 2014-01-14 at 08:40 -0600, Vince Bridgers wrote:
>> > This change adds a parameter for the Synopsys 10/100/1000
>> > stmmac Ethernet driver to configure the maximum frame
>> > size supported by the EMAC driver. Synopsys allows the FIFO
>> > sizes to be configured when the cores are built for a particular
>> > device, but do not provide a way for the driver to read
>> > information from the device about the maximum MTU size
>> > supported as limited by the device's FIFO size.
>> >
>> > Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
>> > ---
>> >
>> >  Documentation/devicetree/bindings/net/stmmac.txt |    5 +++++
>> >  1 file changed, 5 insertions(+)
>> >
>> > diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
>> > b/Documentation/devicetree/bindings/net/stmmac.txt index eba0e5e..=
26a0ba9
>> > 100644
>> > --- a/Documentation/devicetree/bindings/net/stmmac.txt
>> > +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>> >
>> > @@ -30,6 +30,10 @@ Required properties:
>> >  Optional properties:
>> >  - mac-address: 6 bytes, mac address
>> >
>> > +- snps,max-frame-size:     Maximum frame size permitted. This par=
ameter is
>> > useful
>> I don't think max-frame-size should be a snps-only binding.
>
> Right, and I already made that comment to Vince. Maybe this is just a=
n
> oversight and mistakenly resubmitted v2 instead of v3?
> --
> Florian
