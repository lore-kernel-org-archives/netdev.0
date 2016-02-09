From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Tue, 09 Feb 2016 15:47:24 +0100
Message-ID: <14388522.9LWflTAYzq@wuerfel>
References: <1454962873-1941-1-git-send-email-bernhard@bwalle.de> <3171793.SonfZDNmtV@wuerfel> <20160208215138.GB13673@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Bernhard Walle <bernhard@bwalle.de>, fabio.estevam@freescale.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160208215138.GB13673@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 08 February 2016 22:51:38 Andrew Lunn wrote:
> On Mon, Feb 08, 2016 at 10:46:42PM +0100, Arnd Bergmann wrote:
> > On Monday 08 February 2016 21:21:13 Bernhard Walle wrote:
> > > We need that for a custom hardware that needs the reverse reset
> > > sequence.
> > > 
> > > Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
> > > 
> > 
> > Why can't this be specified in the gpios property?
> 
> Backwards compatibility. The flag has always been ignored until now,
> yet various DTs have a flag value which are active low. If suddenly it
> worked, various boards would break 

Ok, I see. 

	Arnd
