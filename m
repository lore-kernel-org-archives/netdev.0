From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] pci: push deprecated pci_find_device() function to
	last user
Date: Wed, 13 Jan 2010 20:43:31 -0800
Message-ID: <20100114044331.GA29008@suse.de>
References: <4B4B802A.2010709@imap.cc> <20100111200136.GA29955@suse.de> <20100113142328.5DE2F40107@xenon.ts.pxnet.com> <20100113.203338.52448956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tilman@imap.cc, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn@linux-pingi.de,
	isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52146 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751713Ab0ANEnd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 23:43:33 -0500
Content-Disposition: inline
In-Reply-To: <20100113.203338.52448956.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 08:33:38PM -0800, David Miller wrote:
> From: Tilman Schmidt <tilman@imap.cc>
> Date: Wed, 13 Jan 2010 15:23:28 +0100 (CET)
> 
> > The ISDN4Linux HiSax driver family contains the last remaining users
> > of the deprecated pci_find_device() function. This patch creates a
> > private copy of that function in HiSax, and removes the now unused
> > global function together with its controlling configuration option,
> > CONFIG_PCI_LEGACY.
> > 
> > Impact: code reorganization, no functional change
> > Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> > ---
> > Note: This patch is not, nor does it intend to be, checkpatch.pl clean.
> > The issues checkpatch.pl reports on it were already present before, and
> > are unrelated to the topic of this patch.
> 
> I'm fine with this, and Greg or whoever else can take this
> through a driver or PCI specific tree if they want:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Where do ISDN patches go through, the network tree?

Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
