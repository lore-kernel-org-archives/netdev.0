From: Aurelien Jarno <aurelien@aurel32.net>
Subject: Re: [PATCH 1/3] SSB EXTIF timing & serial port initialization
Date: Mon, 6 Aug 2007 20:29:55 +0200
Message-ID: <20070806182955.GA32465@hall.aurel32.net>
References: <20070806150447.GB24308@hall.aurel32.net> <200708062023.08046.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org, Felix Fietkau <nbd@openwrt.org>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:54384 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbXHFS37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2007 14:29:59 -0400
Content-Disposition: inline
In-Reply-To: <200708062023.08046.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 06, 2007 at 08:23:07PM +0200, Michael Buesch wrote:
> On Monday 06 August 2007, Aurelien Jarno wrote:
> > The patch below adds a new file drivers/ssb/driver_extif.c which
> > contains new SSB EXTIF functions to initializes the timing and the
> > serial ports.
> > 
> > Cc: Felix Fietkau <nbd@openwrt.org>
> > Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>
> 
> > +#ifdef CONFIG_SSB_SERIAL
> > +static bool serial_exists(u8 *regs)
> > +{
> > +	u8 save_mcr, msr = 0;
> > +
> > +	if (regs) {
> > +		save_mcr = regs[UART_MCR];
> > +		regs[UART_MCR] = (UART_MCR_LOOP | UART_MCR_OUT2 | UART_MCR_RTS);
> > +		msr = regs[UART_MSR] & (UART_MSR_DCD | UART_MSR_RI \
>                                                                  ^^^^^
> Backslash?
> 

Oops I did too much shell scripts recently ;-) I will send a new patch.

-- 
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
