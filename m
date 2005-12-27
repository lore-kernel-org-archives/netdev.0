From: Deepak Saxena <dsaxena@plexity.net>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Tue, 27 Dec 2005 15:12:28 -0800
Message-ID: <20051227231228.GD31728@plexity.net>
References: <20051220230806.619131000@localhost.localdomain>
	<200512211548.23070.sr@denx.de> <20051224140752.GC9840@plexity.net>
	<200512271045.24105.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Stefan Roese <sr@denx.de>
Content-Disposition: inline
In-Reply-To: <200512271045.24105.sr@denx.de>
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

On Dec 27 2005, at 10:45, Stefan Roese was caught saying:
> 
> Understood. But a total rewrite of this code is unfortunately not an option, 
> since it's just too much work (without a sponsor).
> 
> > > It most likely is the same code. Currently it's version 2.0. This version
> > > is available under a special Intel license
> > > (http://www.intel.com/design/network/products/npfamily/ixp425swr1.htm)
> > > and under the BSD license (when you bug your Intel contact enough). The
> > > files seem to be the same, only the header with the license is exchanged.
> >
> > I'll take a look a this some more, but is it just the HAL or the whole
> > stack that's open?
> 
> It's the complete ixp400 access library. The file available via the link above 
> is called "IPL_ixp400AccessLibrary-2_0.zip" and the BSD version of it is 
> called "BSD_ixp400AccessLibrary-2_0.zip". Only the license headers seem to be 
> replaced. As I heard the 2.1 version should also be available in the BSD 
> version in december, but I didn't get access to it until now.

If it ss already licensed as BSD minus the advertising clause, just make
your customer happy and integrate it as is into their kernel. There is
no point making a clean version of the library as it will never go
upstream.

~Deepak

-- 
Deepak Saxena - dsaxena@plexity.net - http://www.plexity.net

A starving child in Africa or you in front of your TV?
Where's the real tragedy?

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
