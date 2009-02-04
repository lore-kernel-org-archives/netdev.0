From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.29-rc: unable to compile e100 firmware into kernel
Date: Wed, 04 Feb 2009 13:33:04 +0000
Message-ID: <1233754384.19223.183.camel@macbook.infradead.org>
References: <200901311900.00851.arvidjaar@mail.ru>
	 <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrey Borzenkov <arvidjaar@mail.ru>, linux-kbuild@vger.kernel.org,
	netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40036 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758817AbZBDNdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 08:33:10 -0500
In-Reply-To: <4807377b0902011105l29e846c3r140212ac654efb93@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-02-01 at 11:05 -0800, Jesse Brandeburg wrote:
> On Sat, Jan 31, 2009 at 7:59 AM, Andrey Borzenkov <arvidjaar@mail.ru> wrote:
> > {pts/2}% LC_ALL=C make -C ~/src/linux-git O=$HOME/build/linux-2.6.29
> > make: Entering directory `/home/bor/src/linux-git'
> >  Using /home/bor/src/linux-git as source for kernel
> > ln -fsn /home/bor/src/linux-git source
> 
> I think (seem to recall something on the list) there have been
> multiple people reporting the make O= option doesn't work with
> CONFIG_FIRMWARE_IN_KERNEL,

That shouldn't be the case -- it works fine here.

Andrey, what version of make are you using? Does it give you any clues
if you use 'make V=1' or 'make -d firmware/built-in.o' ?  

>  but what does the CONFIG_PREVENT_FIRMWARE_BUILD=y option do?  If it
> does what it appears to by its title, looks like you might need to set
> that to =n

Nah, that's something entirely different. That's for GPL-compatible
firmware where we actually _have_ the source in the kernel tree too, but
the user probably doesn't have the required tools so we don't usually
bother rebuilding it.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

