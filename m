From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Driver for IXP4xx built-in Ethernet ports
Date: Sat, 03 May 2008 00:09:12 +0200
Message-ID: <m3zlr8qrxz.fsf@maximus.localdomain>
References: <m3r6d05ucg.fsf@maximus.localdomain> <4816B99F.7040102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:36586 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757175AbYEBWJP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 18:09:15 -0400
In-Reply-To: <4816B99F.7040102@garzik.org> (Jeff Garzik's message of "Tue\, 29 Apr 2008 02\:01\:03 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

> the ifdefs are really ugly and want cleaning, but the rest seems
> sane. applied

Thanks.

They (#ifdef __ARMEB__) are indeed very ugly but I don't know how to
clean them, except by splitting the driver into two (which is worse).

The most used things are #defined and then used without those
__ARMEB__ checks.

Duplicating those functions is effectively splitting into two :-(

Well, perhaps Intel could give us firmware which could convert LE-BE
on the fly while TX/RX, that would make the LE code go away.
Binary-only :-(

OTOH I could convert #if* DEBUG_*, I will look at it.
-- 
Krzysztof Halasa
