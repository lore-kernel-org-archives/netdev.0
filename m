From: Damien Riegel <damien.riegel@savoirfairelinux.com>
Subject: Re: [PATCH v2 3/3] can: sja1000: of: add compatibility with
 Technologic Systems version
Date: Tue, 12 Jan 2016 10:51:15 -0500
Message-ID: <20160112155115.GA6050@localhost>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com>
 <1450978973-30417-4-git-send-email-damien.riegel@savoirfairelinux.com>
 <5694B17A.10406@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5694B17A.10406@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 12, 2016 at 08:55:38AM +0100, Marc Kleine-Budde wrote:
> On 12/24/2015 06:42 PM, Damien Riegel wrote:
> > Technologic Systems provides an IP compatible with the SJA1000,
> > instantiated in an FPGA. Because of some bus widths issue, access to
> > registers is made through a "window" that works like this:
> > 
> >     base + 0x0: address to read/write
> >     base + 0x2: 8-bit register value
> 
> Why do you use io{read,write}16 if it's a 8 bit register?

8-bit is at the IP level, but the bus between the SoC and the FPGA only
supports 16-bit wide access. The point of the window is to convert
between 16-bit and 8-bit access.

Damien
