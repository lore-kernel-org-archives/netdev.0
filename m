From: "Gilles Espinasse" <g.esp@free.fr>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Fri, 16 May 2008 22:08:29 +0200
Message-ID: <0f7201c8b790$9c2a2340$f9b5a8c0@pii350>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550 <20080516161029.44ded734@core>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp7-g19.free.fr ([212.27.42.64]:40523 "EHLO smtp7-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755621AbYEPULY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 16:11:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message ----- 
From: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
To: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Cc: "Jeff Garzik" <jeff@garzik.org>; "Kok, Auke" <auke-jan.h.kok@intel.com>;
"Rick Jones" <rick.jones2@hp.com>; "Brandeburg, Jesse"
<jesse.brandeburg@intel.com>; "Chris Peterson" <cpeterso@cpeterso.com>;
<netdev@vger.kernel.org>; <linux-kernel@vger.kernel.org>
Sent: Friday, May 16, 2008 5:10 PM
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
IRQF_SAMPLE_RANDOM


> > receives no input.  While ethernet might not be preferable if you have
> > something else, sometimes you really don't have anything else.
>
> Ethernet is observable so ethernet isn't entropy. There is no "anything
> else" here -> there is no *anything*
> --
That's funny
It does look to disturb some kernel developper that ethernet may be sniffed
to feed a RNG
even that could be very hard to reach any effective result in the case of a
machine splitting
different network segments.

In the same time, it does not disturb openssl developpers to include non
initialised
memory that may or may not be predictable to feed a RNG.
http://marc.info/?l=openssl-dev&m=121095151003011&w=2

 Gilles

