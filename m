From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Mon, 17 Nov 2014 14:56:45 +0000
Message-ID: <915054555B5659448ACF8A70E114824D01704BD71E@Exchange2010.kamstrup.dk>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
 <20141111194101.GI29789@localhost>
 <915054555B5659448ACF8A70E114824D01704B9131@Exchange2010.kamstrup.dk>
 <20141115141804.GA24633@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
	"bruno.thomsen@gmail.com" <bruno.thomsen@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141115141804.GA24633@localhost>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Did you specify a led-mode as well, or was the Operation Mode Strap Override (OMSO) write the first access after the soft reset?
No led-mode was specified so OMSO was the first write.

> Did you try any other workarounds besides setting the clock mode before doing the OMSO write?
I spend around 2 weeks hunting down the bug.
During which I tried many things in both the Freescale FEC MAC driver and the Micrel PHY driver.
Changing the init and the probe flow as well as adding a lot of extra debug traces.

> And REF_CLK (pin 16) is not connected? 
Yes, pin 16 is floating.

> Would you able to test my series on your setup, and possibly a couple of diagnostic patches on top?
Sure, I can try later this week.

/Bruno
