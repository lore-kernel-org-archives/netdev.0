From: Jaswinder Singh Rajput <jaswinder@kernel.org>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Wed, 21 Jan 2009 05:18:55 +0530
Message-ID: <1232495335.3123.13.camel@localhost.localdomain>
References: <1232463174.3088.15.camel@localhost.localdomain>
	 <1232463242.3088.16.camel@localhost.localdomain>
	 <200901201847.03030.arnd@arndb.de>  <m3zlhlycso.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:59856 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756655AbZATXtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jan 2009 18:49:22 -0500
In-Reply-To: <m3zlhlycso.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 20:53 +0100, Krzysztof Halasa wrote:
> Arnd Bergmann <arnd@arndb.de> writes:
> 
> > The CONFIG_DLCI check in there is clearly in error, the definition in there
> > is a user interface. The obvious solution is to drop the #if / #endif pair
> > without a replacement.
> 
> I think so.
> OTOH I'd be really surprised if anyone on the planet still used this
> code/driver. IIRC and AFAICS it is (sdla.c coupled with dlci.c) the
> first driver for the old Sangoma ISA sync serial cards (S502 - S508,
> i.e. those based on Z80CPU doing HDLC and other things in firmware).
> 
> 

usr/include/linux/if_frad.h is covered with CONFIG_DLCI from many years
and no body is complaining about it so it means no body is using it.

So should we need to drop #if / #endif pair or the whole file from
userspace.

--
JSR

