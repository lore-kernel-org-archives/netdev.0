From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Thu, 31 Aug 2017 09:31:16 +0200
Message-ID: <201708310931.16406.linux@rainbow-software.org>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
 <201708292332.58569.linux@rainbow-software.org>
 <20170831043042.GB3359@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, samuel@sortiz.org,
 David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170831043042.GB3359@kroah.com>
Content-Disposition: inline
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

On Thursday 31 August 2017, Greg KH wrote:
> On Tue, Aug 29, 2017 at 11:32:58PM +0200, Ondrej Zary wrote:
> > On Tuesday 29 August 2017 01:42:08 David Miller wrote:
> > > From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > > Date: Sun, 27 Aug 2017 17:03:30 +0200
> > >
> > > > The IRDA code has long been obsolete and broken.  So, to keep people
> > > > from trying to use it, and to prevent people from having to maintain
> > > > it, let's move it to drivers/staging/ so that we can delete it
> > > > entirely from the kernel in a few releases.
> > >
> > > No objection, I'll apply this to net-next, thanks Greg.
> >
> > IRDA works fine in Debian 9 (kernel 4.9) and I use it for simple file
> > transfer. Hope I'm not the only one...
> >
> > # irattach /dev/ttyS0 -d tekram -s
> > # irdadump
> > 21:28:52.830350 xid:cmd aed8eb79 > ffffffff S=6 s=0 (14)
> > 21:28:52.922368 xid:cmd aed8eb79 > ffffffff S=6 s=1 (14)
> > 21:28:53.014350 xid:cmd aed8eb79 > ffffffff S=6 s=2 (14)
> > 21:28:53.106338 xid:cmd aed8eb79 > ffffffff S=6 s=3 (14)
> > 21:28:53.190276 xid:rsp aed8eb79 < 000035d1 S=6 s=3 Nokia 6230i hint=b125
> > [ PnP Modem Fax Telephony IrCOMM IrOBEX ] (28)
> > 21:28:53.198384 xid:cmd aed8eb79 > ffffffff S=6 s=4 (14)
> > 21:28:53.290382 xid:cmd aed8eb79 > ffffffff S=6 s=5 (14)
> > 21:28:53.382341 xid:cmd aed8eb79 > ffffffff S=6 s=* pentium hint=0400 [
> > Computer ] (23)
> > ^C
> > 8 packets received by filter
> >
> > $ obexftp -i -l MMC
> > Connecting..\done
> > Receiving "MMC".../<?xml version="1.0"?>
> > <!DOCTYPE folder-listing SYSTEM "obex-folder-listing.dtd"
> >  [ <!ATTLIST folder mem-type CDATA #IMPLIED> ]>
> > <folder-listing version="1.0">
> >     <parent-folder />
> >     <file name="Image000.jpg" size="304300" modified="20160219T135924"
> > user-perm="RWD"/>
> >     <file name="Image001.jpg" size="270037" modified="20170811T233122"
> > user-perm="RWD"/>
> >     <file name="Image004.jpg" size="53519" modified="20170814T074550"
> > user-perm="RWD"/>
> > ....
> > $ obexftp -i -c MMC -g Image004.jpg
> > Connecting..\done
> > Sending "MMC"...|done
> > Receiving "Image004.jpg"...-done
> > Disconnecting..\done
>
> Odd, and is this just a ir device connected to a "real" serial port, or
> a specific IRDA device?
>
> thanks,
>
> greg k-h

Yes, it's an external IrDA dongle connected to a real serial port.

I also have an ARK3116-based USB IrDA dongle and some laptops with integrated 
IrDA ports that used to work fine but haven't tested them recently (i.e. 
Debian 9).

-- 
Ondrej Zary
