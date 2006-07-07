From: Andi Kleen <ak@suse.de>
Subject: Re: skge error; hangs w/ hardware memory hole
Date: Fri, 7 Jul 2006 23:28:51 +0200
Message-ID: <200607072328.51282.ak@suse.de>
References: <20060703205238.GA10851@deprecation.cyrius.com> <20060707141843.73fc6188@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Martin Michlmayr <tbm@cyrius.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, 341801@bugs.debian.org,
	asd@suespammers.org, kevin@sysexperts.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:13237 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932314AbWGGV3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 17:29:16 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060707141843.73fc6188@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 07 July 2006 23:18, Stephen Hemminger wrote:
> On Mon, 3 Jul 2006 22:52:38 +0200
> Martin Michlmayr <tbm@cyrius.com> wrote:
> 
> > We received the following bug report at http://bugs.debian.org/341801
> > 
> > | I have a Asus A8V with 4GB of RAM. When I turn on the hardware memory
> > | hole in the BIOS, the skge driver prints out this message:
> > |       skge hardware error detected (status 0xc00)
> > | and then does not work. Setting debug=16 doesn't really show anything.


Is that a board with VIA chipset?

VIA doesn't seem to support PCI accesses with addresses >4GB and they also
don't have a working GART IOMMU.

It will likely work with iommu=force

I've been pondering to force this, but was still waiting for more reports.

-Andi

