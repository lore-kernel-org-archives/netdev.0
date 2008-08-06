From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Tue, 5 Aug 2008 23:18:00 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0808052308080.15995@nehalem.linux-foundation.org>
References: <20080805.190020.244441681.davem@davemloft.net> <alpine.LFD.1.10.0808051937410.15995@nehalem.linux-foundation.org> <A0AAD67C-1F54-4D85-A413-91BBBE044452@holtmann.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ivo van Doorn <IvDoorn@gmail.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57757 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757795AbYHFGSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 02:18:37 -0400
In-Reply-To: <A0AAD67C-1F54-4D85-A413-91BBBE044452@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 6 Aug 2008, Marcel Holtmann wrote:
> 
> I looked at the driver and got it working. However my 901 seems to have an
> issue with the antennas. I can do scans, but associating with an access point
> or even thinking about transmit keeps failing. Even with external antennas
> this still doesn't work. So either my EeePC is broken or it needs some ACPI
> magic to enable it. Personally I think mine is broken since the PCIe hotplug
> stuff works for the wireless card and that seems to be their way of doing the
> rfkill.

Yeah, the rfkill literally makes the chip go away from the PCI lists, it 
seems. But your problems can certainly be somehow driver-related, I 
haven't actually _tested_ that thing at all, I got the machine just as the 
merge window started, so I've had no time to even play with it.

> The driver itself is painful. It is full of ifdefs and some crazy build magic.
> The integrated (to some degree optional) WPA code is pretty ugly. It has also
> a full set of iwpriv commands to do all the settings etc. :(

Well, it's also trying to support both 2.4.x and 2.6 etc. Yeah, that is 
horrid. At the same time, I can't say that the "rewrite it entirely" 
approach of the previous-gen cards has worked very well either, since that 
seems to have just perpetuated the problems. It would be great to try to 
educate them, but I'm not finding even an email address in the sources.

Oh well. I can't really complain, since just the fact that they bothered 
to even make sources available still makes them pretty responsible people, 
even if the sources are pretty dang ugly.

All the capitalization etc makes me think they are all old DOS and Windows 
programmers. UCHAR and USHORT indeed, along with CamelCase functions. 

I dunno. 

			Linus
