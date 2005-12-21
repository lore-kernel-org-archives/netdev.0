From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Integrating IXP4xx NPE support in kernel (with IXP4xx
	accesslibrary)
Date: Thu, 22 Dec 2005 00:37:20 +0100
Message-ID: <20051221233720.GB24700@xi.wantstofly.org>
References: <20051220230806.619131000@localhost.localdomain>
	<200512211300.38163.sr@denx.de>
	<20051221135230.GA22807@xi.wantstofly.org>
	<200512211548.23070.sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
To: Stefan Roese <sr@denx.de>
Content-Disposition: inline
In-Reply-To: <200512211548.23070.sr@denx.de>
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

On Wed, Dec 21, 2005 at 03:48:22PM +0100, Stefan Roese wrote:

> Hi Lennert,

Hello,


> > > The main question I have is, where should the IXP4xx access-library
> > > be located in the kernel directory structure?
> >
> > Maybe you can explain to the list readers what it is and what it does?
> 
> It's the library needed for the NPE (network processor engines)
> ethernet driver to access the on chip NPE's (e.g. download microcode,
> communicate with the NPE's etc.). Unfortunately a pretty big piece of
> software written to support multiple OS's. :-(

So that means that there are wrappers for malloc and free and stuff
like that?  Doesn't sound very likely that you'll get that merged..


> > > Please comment on this and let me know if such an effort has any chance
> > > of getting accepted into the official kernel.
> >
> > Assuming that the license issues have all been worked out now, it'll
> > mostly depend on the quality of the code.  (If this is the same Intel
> > code that I saw a while ago, I think it'll need a fair amount of work
> > before it can go in.)
> 
> It most likely is the same code. Currently it's version 2.0. This
> version is available under a special Intel license 
> (http://www.intel.com/design/network/products/npfamily/ixp425swr1.htm)
> and under the BSD license (when you bug your Intel contact enough).
> The files seem to be the same, only the header with the license is
> exchanged.

That sounds very fishy -- are you 100% sure that the person doing the
s/Proprietary/BSD/ was in fact authorized to do so?  (This is one reason
why I'd love to see someone @intel.com submit this code upstream, BTW.)


cheers,
Lennert

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
