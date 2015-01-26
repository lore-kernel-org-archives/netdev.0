From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: make allyesconfig i386 build failure with next-20150122 (caused
 by fb_agm1264k-fl driver)
Date: Mon, 26 Jan 2015 14:46:54 -0800
Message-ID: <20150126224654.GA17166@kroah.com>
References: <CA+r1ZhhXF+hicy7JKo3jAbgSbO4KOLm6BwPosTKNb+E_Cb4yPQ@mail.gmail.com>
 <20150126215959.GA9853@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel <devel@driverdev.osuosl.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
 isdn@linux-pingi.de, netdev <netdev@vger.kernel.org>,
 linux-kernel <linux-kernel@vger.kernel.org>,
 linux-next <linux-next@vger.kernel.org>, Jim Davis <jim.epost@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150126215959.GA9853@roeck-us.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2015 at 01:59:59PM -0800, Guenter Roeck wrote:
> On Thu, Jan 22, 2015 at 12:10:33PM -0700, Jim Davis wrote:
> > make ARCH=i386 allyesconfig fails with
> > 
> > drivers/staging/built-in.o: In function `reset':
> > (.text+0x2ae89d): multiple definition of `reset'
> > drivers/isdn/built-in.o:(.text+0x185dc2): first defined here
> > make[1]: *** [drivers/built-in.o] Error 1
> 
> Culprit:
> 
> commit b2ebd4be6fa1d2329b63531b044f9e25474981cb
> Author: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Date:   Wed Dec 31 10:11:10 2014 +0100
> 
>     staging: fbtft: add fb_agm1264k-fl driver
> 
> A global function named 'reset' isn't really a good idea.
> 
> Not that the global function with the same name in the isdn code
> is better ;-).

Agreed, the fbtft code is now fixed.  Patches to fix the isdn code would
be gladly accepted as well :)

thanks,

greg k-h
