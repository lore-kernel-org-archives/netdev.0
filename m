From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] s2io ppc64 fix for readq/writeq
Date: Mon, 06 Nov 2006 19:52:58 +1100
Message-ID: <1162803178.28571.300.camel@localhost.localdomain>
References: <1162780109.28571.273.camel@localhost.localdomain>
	 <454EE943.6000603@pobox.com>
	 <1162800248.28571.296.camel@localhost.localdomain>
	 <454EF07B.4010503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58008 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1423624AbWKFIyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:54:14 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <454EF07B.4010503@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> This is why I said "good enough for drivers".  This is _key_.
> 
> I have run into several [PCI] devices with 64-bit registers, and 
> __none__ of them had requirements such that the Linux platform code 
> -must- provide an atomic readq/writeq.  Probably because everybody wants 
> to support 32-bit platforms with their devices.
> 
> What you call "fairly bogus" is precisely what drivers need.  These 
> devices with 64-bit registers just don't need the atomicity that arch 
> developers harp about :)

Is there any consistency in that case in which half need to be
read/written first ? Or none of these ever had side effects ?

Ben.


