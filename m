From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [GIT]: Networking
Date: Wed, 6 Aug 2008 10:22:02 +0200
Message-ID: <200808061022.02432.IvDoorn@gmail.com>
References: <20080805.190020.244441681.davem@davemloft.net> <A0AAD67C-1F54-4D85-A413-91BBBE044452@holtmann.org> <alpine.LFD.1.10.0808052308080.15995@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:45777 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbYHFH4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 03:56:55 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1078774nfc.21
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 00:56:55 -0700 (PDT)
In-Reply-To: <alpine.LFD.1.10.0808052308080.15995@nehalem.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 06 August 2008, Linus Torvalds wrote:
> 
> On Wed, 6 Aug 2008, Marcel Holtmann wrote:
> > 
> > I looked at the driver and got it working. However my 901 seems to have an
> > issue with the antennas. I can do scans, but associating with an access point
> > or even thinking about transmit keeps failing. Even with external antennas
> > this still doesn't work. So either my EeePC is broken or it needs some ACPI
> > magic to enable it. Personally I think mine is broken since the PCIe hotplug
> > stuff works for the wireless card and that seems to be their way of doing the
> > rfkill.
> 
> Yeah, the rfkill literally makes the chip go away from the PCI lists, it 
> seems. But your problems can certainly be somehow driver-related, I 
> haven't actually _tested_ that thing at all, I got the machine just as the 
> merge window started, so I've had no time to even play with it.
> 
> > The driver itself is painful. It is full of ifdefs and some crazy build magic.
> > The integrated (to some degree optional) WPA code is pretty ugly. It has also
> > a full set of iwpriv commands to do all the settings etc. :(
> 
> Well, it's also trying to support both 2.4.x and 2.6 etc. Yeah, that is 
> horrid. At the same time, I can't say that the "rewrite it entirely" 
> approach of the previous-gen cards has worked very well either, since that 
> seems to have just perpetuated the problems. It would be great to try to 
> educate them, but I'm not finding even an email address in the sources.

I've send a mail to Ralink with a request if they could step away from the
"port the windows driver to linux" idea and get the Linux driver "kernel-ready"
early on.
That won't solve the problem now, but hopefully it does mean the drivers for
the next generation can go into the kernel sooner.

> Oh well. I can't really complain, since just the fact that they bothered 
> to even make sources available still makes them pretty responsible people, 
> even if the sources are pretty dang ugly.
> 
> All the capitalization etc makes me think they are all old DOS and Windows 
> programmers. UCHAR and USHORT indeed, along with CamelCase functions. 

Well it basically is the Windows driver ported to Linux. ;)

Ivo
