From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2009-06-04
Date: Sun, 7 Jun 2009 11:26:20 -0400
Message-ID: <20090607152620.GC2736@tuxdriver.com>
References: <20090604152011.GC2839@tuxdriver.com> <20090607.033751.191866033.davem@davemloft.net> <4A2BCC41.1060508@hartkopp.net> <20090607145830.GA2736@tuxdriver.com> <4A2BD8A5.4040302@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48356 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbZFGPa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2009 11:30:29 -0400
Content-Disposition: inline
In-Reply-To: <4A2BD8A5.4040302@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 07, 2009 at 05:11:33PM +0200, Oliver Hartkopp wrote:
> John W. Linville wrote:
> > On Sun, Jun 07, 2009 at 04:18:41PM +0200, Oliver Hartkopp wrote:
> >> David Miller wrote:
> >>> From: "John W. Linville" <linville@tuxdriver.com>
> >>> Date: Thu, 4 Jun 2009 11:20:11 -0400
> >>>
> >>>> Hopefully this is (almost?) the last wireless pull request for
> >>>> non-bugfix patches intended for 2.6.31...
> >>>>
> >> (..)
> >>
> >>>> Please let me know if there are problems!
> >>> Pulled into net-next-2.6 and I'll push it back out to kernel.org
> >>> after some build testing.
> >> Hi John,
> >>
> >> after pulling the latest net-next-2.6 i got this warning which is probably
> >> caused by CONFIG_RFKILL=m in my config:
> >>
> >> hartko@vwagwolkf320:~/net-next-2.6$ make oldconfig
> >> scripts/kconfig/conf -o arch/x86/Kconfig
> >> .config:614:warning: symbol value 'm' invalid for RFKILL_INPUT
> > 
> > That functionality is no longer available as a module.  If you need
> > it, then select Y.
> 
> Just some additional nitpicking:
> 
> You should update net/rfkill/Kconfig as it still allows a tristate selection
> for RFKILL and the comment "To compile this driver as a module ..." should be
> removed also.

RFKILL and RFKILL_INPUT are different things... :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
