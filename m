From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 23 May 2006 16:14:27 +0100
Message-ID: <1148397268.25255.81.camel@localhost.localdomain>
References: <44731733.7000204@ti-wmc.nl>
	 <1148395738.25255.68.camel@localhost.localdomain>
	 <44731F2C.2010109@ti-wmc.nl> <20060523145549.GA22749@harddisk-recovery.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Simon Oosthoek <simon.oosthoek@ti-wmc.nl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herman Elfrink <herman.elfrink@ti-wmc.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932232AbWEWPAw@vger.kernel.org>
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060523145549.GA22749@harddisk-recovery.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Maw, 2006-05-23 at 16:55 +0200, Erik Mouw wrote:
> > >Ethernet protocol number I assume you mean. If so this at least used to
> > >be handled by the IEEE, along with ethernet mac address ranges.
> > >
> > 
> > Yes ethernet protocol (it's below IP level), I didn't realise that IEEE 
> > also handled the portnumbers. I'll check the ieee website to see how it 
> > works, tnx!
> 
> IEEE doesn't handle port numbers. Port numbers are for whatever is
> layered on top of ethernet, so you need to register those with the
> appropriate authorities (IANA for IP).

No no no

There are several sets of numbers here

Each ethernet DIX frame has a "protocol" (its the bits used for length
in 802.*). IEEE at least used to handle the assignment of those. On top
of that you have IP, IPX, etc with their own numbering agency.

As he said "ethernet protocol (it's below IP level)", those are the
protocol numbering bodies he wants, or to whomever it was delegated.

Alan
