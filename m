From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 0/3] Altera Triple Speed Ethernet (TSE) Driver RFC
Date: Mon, 3 Mar 2014 09:53:10 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6CEC12@AcuExch.aculab.com>
References: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"rob@landley.net" <rob@landley.net>
To: 'Vince Bridgers' <vbridgers2013@gmail.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1393792922-2381-1-git-send-email-vbridgers2013@gmail.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers
> I'm submitting this patch set for comments as a first step towards upstreaming
> a driver for the Altera Triple Speed Ethernet (TSE) controller.
...
> The design has been tested on Altera's Cyclone 4, 5, and Cyclone 5 SOC
> development kits using an ARM A9 processor and an Altera NIOS2 processor.

I'm not sure this is relevant to any decision to import this but
as far as I know the nios2 port of gcc is not is part of the main gcc
release.
(If it was it would be easier to get fixes applied!)

I'm also not entirely convinced that Linux is an appropriate
operating system for a 100MHz nios2 cpu. You'll certainly have
problems processing Ge data rates (and maybe 100M ones as well).

	David



