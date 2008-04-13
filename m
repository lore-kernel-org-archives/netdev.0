From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Sun, 13 Apr 2008 23:34:14 +0200
Message-ID: <200804132334.21654.linux@rainbow-software.org>
References: <47FBDBE9.9040700@garzik.org> <47FFF7B5.3000609@garzik.org> <alpine.LFD.1.00.0804131410340.2982@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Daniel Barkalow <barkalow@iabervon.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:46271 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752305AbYDMVe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 17:34:29 -0400
In-Reply-To: <alpine.LFD.1.00.0804131410340.2982@woody.linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 13 April 2008 23:13:01 Linus Torvalds wrote:
> On Fri, 11 Apr 2008, Jeff Garzik wrote:
> > Linus Torvalds wrote:
> > > .. but that said, I think your patch is certainly better than what we
> > > have now (or what Ingo was complaining about for the next merge
> > > window). I certainly could live with it. I would just suggest against
> > > ever then removing that "generic E1000" choice.
> >
> > You mean never ever remove PCI-E support from e1000?
>
> No. I mean never ever remove the *configure* level thinking that "e1000 is
> e1000".
>
> There is no sense in *ever* showing it as two drivers to users, because
> users do not see them as separate chipsets. They look identical, down to
> the part names.
>
> If it's a single family, and users can't even easily tell whether they
> have version 1 or version 2 (PCI vs PCI-E), you shouldn't even ask them.
> You should literally ask them: "do you want e1000 support".

It's something like RTL8139. There are two versions of the chips. They even 
have the same PCI IDs. But there are two different drivers - 8139cp and 
8139too. It's really bad for users

>
> That's it.
>
> Once you have asked them that, you can then decide "ok, if you *really*
> know what version of the chip you have, you can decide to only get limited
> driver support".
>
> But that's a secondary thing from a user perspective.
>
> See the patch I already sent out.
>
> 			Linus
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Ondrej Zary
