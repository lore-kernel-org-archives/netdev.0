From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can someone please try...
Date: Thu, 18 Jan 2007 04:41:14 -0500
Message-ID: <1169113274.10770.18.camel@dv>
References: <200701161806.02780.mb@bu3sch.de>
	 <200701162307.02891.mb@bu3sch.de> <1168991519.17787.17.camel@dv>
	 <200701171052.12855.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:54113 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbXARJlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jan 2007 04:41:19 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1H7Tl6-0001Lw-Fs
	for netdev@vger.kernel.org; Thu, 18 Jan 2007 04:40:36 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701171052.12855.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-01-17 at 10:52 +0100, Michael Buesch wrote:

> Doesn't happen for me. I have no idea what's happening.
> Care to debug it?
> But it's weird that _killing_ the supplicant calls add_interface.
> I'd expect it to call remove_interface.

I'm sorry, I was actually running wpa_supplicant again at the time of
the crash.

What I have now is very different behavior in two configurations on the
same machine.

The i386 kernel without SMP with most debug enabled and serial console.
wpa_supplicant times out.  If I restart is, the kernel oopses, every
time in a different place.

The x86_64 kernel with SMP and with very few debug options.
wpa_supplicant connects.  Killing and restarting wpa_supplicant doesn't
cause any problems.  In fact, wpa_supplicant reconnects quickly.  I can
even ping the station from the AP, but the packet loss is horrible.  It
appears that most loss is on the receiving side.

I'll try to debug the problem when I have time.  At least I'll try to
find out if it's specific to the architecture or to another kernel
option.

Anyway, it's exciting that I could send first packets today!

-- 
Regards,
Pavel Roskin


