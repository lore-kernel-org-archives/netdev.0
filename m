From: Stefan Roese <sr@denx.de>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Tue, 27 Dec 2005 10:54:39 +0100
Message-ID: <200512271054.39629.sr@denx.de>
References: <20051220230806.619131000@localhost.localdomain>
	<20051224140752.GC9840@plexity.net>
	<20051224163653.GB18167@buici.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Deepak Saxena <dsaxena@plexity.net>,
	linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Marc Singer <elf@buici.com>
In-Reply-To: <20051224163653.GB18167@buici.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Saturday 24 December 2005 17:36, Marc Singer wrote:
> > > It most likely is the same code. Currently it's version 2.0. This
> > > version is available under a special Intel license
> > > (http://www.intel.com/design/network/products/npfamily/ixp425swr1.htm)
> > > and under the BSD license (when you bug your Intel contact enough). The
> > > files seem to be the same, only the header with the license is
> > > exchanged.
> >
> > I'll take a look a this some more, but is it just the HAL or the whole
> > stack that's open?
>
> I chatted with Lennert about this and was, well, amazed.  In reading
> what I see on the web site, it looks to me that the library is still
> heavily guarded. They're publishing a GPL'd 'driver' that links with
> the library.

Yes, that's the ethernet driver using this access lib to communicate with the 
NPE's. This driver is published under the GPL.

> The click-through license establishes the same ol' terms.  "You can
> only distribute this software with a hardware product."
>
> Please show me where this new BSD license appears.

As far as I know, you can't find it on the Intel web site. As mentioned 
earlier, we (or our customer) had a lot of discussions with our Intel 
contacts, about getting a version of this access lib under a license allowing 
us to include it in GPL projects (U-Boot and Linux kernel). Finally we got 
access to this BSD version of this library, which seems to exist for quite 
some time. Please don't ask me why this version is not published officially 
by Intel.
 
Best regards,
Stefan

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
