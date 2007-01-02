From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Tue, 2 Jan 2007 22:52:30 +0100
Message-ID: <200701022252.31442.lists@egidy.de>
References: <20061220210632.183204605@osdl.org> <459197B8.6010403@pobox.com> <20070101103644.02544c46@freekitty>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from re01.intra2net.com ([82.165.28.202]:3408 "EHLO
	re01.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922AbXABWQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 17:16:21 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20070101103644.02544c46@freekitty>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > IMHO, it is bad security policy to allow wake on lan to enabled by
> > > default. The sky2 driver doesn't do WOL until enabled with ethtool.
> >
> > While in general I agree with you on the security principle, this seems
> > like it might break working setups.
> >
> > WOL is a partnership between the motherboard and NIC.  The motherboard
> > must support WOL, or its useless.  And since the motherboard must
> > support WOL, it normally has an on/off switch in BIOS.
> >
> > As such, you're overriding the admin's chosen BIOS setting here.
>
> But there is no way to read the BIOS settings.

true.

> If BIOS was being smart enough to actually, setup the chip, then I can
> look at chip registers on startup and see if it is enabled there.

If the BIOS doesn't setup the chip, WOL won't work if you plug in the power 
cord (instead of just using atx poweroff) and is thus nearly useless. 
Correct?

So I'd propose to read the chip registers and set them to the state they were 
in on bootup.

Kind regards,

Gerd
