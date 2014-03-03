From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH RFC 0/3] Altera Triple Speed Ethernet (TSE) Driver RFC
Date: Mon, 3 Mar 2014 12:11:35 -0600
Message-ID: <CAOwfj2NoaF0Otr2X+TyvNfaUJei3PaZXr0WBu8c_Ongz2EEHxg@mail.gmail.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6CEC12@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"rob@landley.net" <rob@landley.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6CEC12@AcuExch.aculab.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David, thank you for taking the time to review and comment. My
responses are inline.

On Mon, Mar 3, 2014 at 3:53 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Vince Bridgers
>> I'm submitting this patch set for comments as a first step towards upstreaming
>> a driver for the Altera Triple Speed Ethernet (TSE) controller.
> ...
>> The design has been tested on Altera's Cyclone 4, 5, and Cyclone 5 SOC
>> development kits using an ARM A9 processor and an Altera NIOS2 processor.
>
> I'm not sure this is relevant to any decision to import this but
> as far as I know the nios2 port of gcc is not is part of the main gcc
> release.
> (If it was it would be easier to get fixes applied!)

Mentor has released an updated NIOS2 GCC port that can be downloaded
here http://www.mentor.com/embedded-software/sourcery-tools/sourcery-codebench/editions/lite-edition/.
Instructions for building and running Linux on NIOS2 can be found here
http://www.rocketboards.org/foswiki/Documentation/NiosIILinuxUserManual.
The NIOS2 GCC port is in process of being upstreamed by Mentor
Graphics. The Linux port for NIOS2 is in process of being mainlined.

>
> I'm also not entirely convinced that Linux is an appropriate
> operating system for a 100MHz nios2 cpu. You'll certainly have
> problems processing Ge data rates (and maybe 100M ones as well).

I agree that you may not see line rate streaming network performance
even at 100Mbps, but most customers using NIOS2 with TSE don't care
about that - it's the connectivity they are interested in the most.
There are many applications using a small soft processor like the
NIOS2 that can take advantage of the ability to reconfigure soft logic
on an FPGA that need some kind of network connectivity for device to
device communication for data updates at some periodic rate that can
be supported by such a system, or for simple configuration. If more
performance is required a customer is free to choose a different
product.

I'm not sure this opinion has anything to do with the decision to
upstream this particular patch or not since the TSE can be used with
different processors in different configurations that customers demand
and find useful.

All the best,

Vince

>
>         David
>
>
>
