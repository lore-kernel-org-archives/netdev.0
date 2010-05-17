From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] phy/marvell: Add special settings for D-Link DNS-323
	rev C1
Date: Mon, 17 May 2010 11:07:37 +1000
Message-ID: <1274058457.21352.711.camel@pasglop>
References: <1274056058.21352.697.camel@pasglop>
	<20100517005942.GB27301@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Pitre <nico@fluxnic.net>,
	linux-arm-kernel@lists.infradead.org, Herbert Valerio Riedel <hvr@gnu.org>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20100517005942.GB27301@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-05-17 at 02:59 +0200, Wolfram Sang wrote:
> There is a fixup()-callback to prevent boardcode in the drivers. See
> Documentation/networking/phy.txt, last chapter.

Ah nice ! I missed that bit. I'll add a fixup and see if it works.

The problem is that writing to this register seems to be part of a
specific initialization sequence, which is done one way in the linux
driver and differently in the vendor kernel. I don't know whether
I can just 'override' the value and I have no docs for that part.

But I'll definitely give it a go tonight.

Cheers,
Ben.
