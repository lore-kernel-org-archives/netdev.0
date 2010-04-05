From: Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Subject: Re: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002) on
 DEC Alpha Personal Workstation 433au
Date: Mon, 5 Apr 2010 20:59:02 +0200
Message-ID: <20100405185902.GA22607@physik.fu-berlin.de>
References: <20100405171318.GA18915@physik.fu-berlin.de>
 <1270488982.31062.28.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpost1.zedat.fu-berlin.de ([130.133.4.66]:34683 "EHLO
	outpost1.zedat.fu-berlin.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755879Ab0DES7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 14:59:07 -0400
Content-Disposition: inline
In-Reply-To: <1270488982.31062.28.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Mon, Apr 05, 2010 at 10:36:22AM -0700, Joe Perches wrote:
> On Mon, 2010-04-05 at 19:13 +0200, Adrian Glaubitz wrote:
> > Hi guys,
> > 
> > I installed Debian unstable on an old digital workstation "DEC Digital
> > Personal Workstation 433au" (Miata) which has an on-board tulip
> > network controller. I'm not really using that network controller but
> > an off-board intel e1000 controller. However, I found that the tulip
> > driver produces a lot of noise in the message log, the following
> > message is repated periodically and spams the whole message log:
> > 
> > 0000:00:03.0: tulip_stop_rxtx() failed (CSR5 0xf0260000 CSR6 0xb3862002)
> > 
> > Do you think this is related to the fact that no cable is connected to
> > the network controller?
> 
> Probably something is trying periodically to open the device.
> Maybe this helps reduce the message log noise:

Thanks for the patch. I will apply it to a current rc of 2.6.34 and
build a new kernel, probably not before tomorrow as I cannot reboot
the Alpha remotely as the "aboot" boot loader does not boot
automatically.

Thanks,

Adrian
