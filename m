From: Pavel Machek <pavel@ucw.cz>
Subject: Re: Dealing with buggy hardware (was: b44 and 4g4g)
Date: Fri, 11 Jun 2004 11:45:23 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040611094523.GB13834@elf.ucw.cz>
References: <20040531202104.GA8301@ee.oulu.fi> <20040605200643.GA2210@ee.oulu.fi> <20040605131923.232f8950.davem@redhat.com> <20040609122905.GA12715@ee.oulu.fi> <20040610200504.GG4507@openzaurus.ucw.cz> <20040610203442.GA27762@ee.oulu.fi> <20040610211217.GA6634@elf.ucw.cz> <20040611061730.GA8081@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S263763AbUFKJpn@vger.kernel.org>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Content-Disposition: inline
In-Reply-To: <20040611061730.GA8081@ee.oulu.fi>
List-Id: netdev.vger.kernel.org

Hi!

> > Okay, this is probably other problem. When the bug hit, what are the symptoms?
> Total immediate crash without an oops. When the RX ring skbufs are allocated
> with GFP_DMA receives work, but any transmits from > 1GB cause a link
> down/link up (which is just about all of them). With GPF_DMA bounce
> buffers those start working too.
> 
> > > (Or the issue isn't fully understood yet, figuring out what breaks and what
> > > doesn't was basically just trial and error :-/ )
> > 
> > Can you try the driver from broadcom? bcom4400, or how is it
> > called. Its extremely ugly, but might get this kind of stuff right...
> Tried that, it breaks with 4:4 and >1GB in exactly the same way :-)

You might want to report them, then look at diff between latest and
previous versions :-)))).
									Pavel
-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
