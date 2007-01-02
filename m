From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Tue, 2 Jan 2007 20:10:15 +0100
Message-ID: <20070102191015.GA5758@dose.home.local>
References: <20061220210632.183204605@osdl.org> <459197B8.6010403@pobox.com> <20070101103644.02544c46@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:57312 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911AbXABTKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 14:10:17 -0500
Received: from dose.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id 6AF4D25C406
	for <netdev@vger.kernel.org>; Tue,  2 Jan 2007 20:10:14 +0100 (CET)
Received: from scorpion by dose.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1H1p1b-0001VW-32
	for netdev@vger.kernel.org; Tue, 02 Jan 2007 20:10:15 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20070101103644.02544c46@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 01, 2007 at 10:36:44 -0800, Stephen Hemminger wrote:
> On Tue, 26 Dec 2006 16:44:24 -0500
> Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > Stephen Hemminger wrote:
> > > Patches are in order of severity. 1-3 are bug fixes, 4 is a cleanup
> > > of the power state code, and 5 adds wake on lan support.
> > > 
> > > IMHO, it is bad security policy to allow wake on lan to enabled by default.
> > > The sky2 driver doesn't do WOL until enabled with ethtool.
> > 
> > While in general I agree with you on the security principle, this seems 
> > like it might break working setups.
> > 
> > WOL is a partnership between the motherboard and NIC.  The motherboard 
> > must support WOL, or its useless.  And since the motherboard must 
> > support WOL, it normally has an on/off switch in BIOS.
> > 
> > As such, you're overriding the admin's chosen BIOS setting here.
> > 
> > 	Jeff
> 
> But there is no way to read the BIOS settings.
> 
> If BIOS was being smart enough to actually, setup the chip, then I can
> look at chip registers on startup and see if it is enabled there.

Some computers even don't have such a BIOS settings (like my Mac mini).

Btw., I just built 2.6.20-rc3 with patches 4 and 5 and wake on LAN now
works. Thanks for your work.

Regards,
Tino
