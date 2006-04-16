From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [RFC: 2.6 patch] net/irda/irias_object.c: remove unused exports
Date: Sun, 16 Apr 2006 21:07:26 +0200
Message-ID: <1145214446.3809.26.camel@laptopd505.fenrus.org>
References: <20060414114446.GL4162@stusta.de>
	 <20060414164203.GA24146@bougret.hpl.hp.com>
	 <1145209616.3809.14.camel@laptopd505.fenrus.org>
	 <1145212639.5656.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Adrian Bunk <bunk@stusta.de>,
	Samuel.Ortiz@nokia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750801AbWDPTKm@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1145212639.5656.3.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2006-04-16 at 19:37 +0100, Alan Cox wrote:
> On Sul, 2006-04-16 at 19:46 +0200, Arjan van de Ven wrote:
> > > 	Personally, I don't see what this patch buy us...
> > 
> > all the unused exports in the kernel together make a binary kernel 100Kb
> > bigger. It's a case of a lot of little steps I suppose (each export
> > taking like 100 to 150 bytes depending on the size of the function name)
> 
> 
> So why are exports taking us 100-150 bytes, not say 20 which is what I'd
> expect ?

there is the name, the crc, the address, a module name thingy (which I
think is only filled for non-built-in symbols) and I'm sure there's some
padding here and there... 

About 1/3rd of all exports is unused, so killing those is an easy way to
gain back the space...
