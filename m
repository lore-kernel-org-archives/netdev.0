From: Stefan Roese <sr@denx.de>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Tue, 27 Dec 2005 10:45:23 +0100
Message-ID: <200512271045.24105.sr@denx.de>
References: <20051220230806.619131000@localhost.localdomain>
	<200512211548.23070.sr@denx.de> <20051224140752.GC9840@plexity.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: dsaxena@plexity.net
In-Reply-To: <20051224140752.GC9840@plexity.net>
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

On Saturday 24 December 2005 15:07, Deepak Saxena wrote:
> On Dec 21 2005, at 15:48, Stefan Roese was caught saying:
> > Hi Lennert,
> >
> > On Wednesday 21 December 2005 14:52, Lennert Buytenhek wrote:
> > > On Wed, Dec 21, 2005 at 01:00:34PM +0100, Stefan Roese wrote:
> > > > The main question I have is, where should the IXP4xx access-library
> > > > be located in the kernel directory structure?
> > >
> > > Maybe you can explain to the list readers what it is and what it does?
> >
> > It's the library needed for the NPE (network processor engines) ethernet
> > driver to access the on chip NPE's (e.g. download microcode, communicate
> > with the NPE's etc.). Unfortunately a pretty big piece of software
> > written to support multiple OS's. :-(
>
> As I mentioned in my earlier reply, we don't want all those abstractions
> in the kernel.

Understood. But a total rewrite of this code is unfortunately not an option, 
since it's just too much work (without a sponsor).

> > It most likely is the same code. Currently it's version 2.0. This version
> > is available under a special Intel license
> > (http://www.intel.com/design/network/products/npfamily/ixp425swr1.htm)
> > and under the BSD license (when you bug your Intel contact enough). The
> > files seem to be the same, only the header with the license is exchanged.
>
> I'll take a look a this some more, but is it just the HAL or the whole
> stack that's open?

It's the complete ixp400 access library. The file available via the link above 
is called "IPL_ixp400AccessLibrary-2_0.zip" and the BSD version of it is 
called "BSD_ixp400AccessLibrary-2_0.zip". Only the license headers seem to be 
replaced. As I heard the 2.1 version should also be available in the BSD 
version in december, but I didn't get access to it until now.

Best regards,
Stefan

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
