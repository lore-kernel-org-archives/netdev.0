From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 5 Apr 2011 11:49:10 +0100
Message-ID: <20110405104910.GE4797@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
 <20110324162517.GI6466@game.jcrosoft.org>
 <20110331094041.GD3371@pulham.picochip.com>
 <20110405102842.GC22192@game.jcrosoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Andrew Victor <linux@maxim.org.za>,
	linux-arm-kernel@lists.infradead.org
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55840 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab1DEKtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 06:49:15 -0400
Received: by wya21 with SMTP id 21so199800wya.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 03:49:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110405102842.GC22192@game.jcrosoft.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 05, 2011 at 12:28:42PM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> work fine on 9263ek except the IP version detection.
> 
> the at91 macb ip version is supposed to be at 0x0601010C but it's not.
> At least on 9263 it's 0x0001010C. So we can not detect the arch at runtime
> but we can detect that it's a macb.
> 
> So could keep the ifdef for 2 archs but use the ip version on arm

OK, well I think my patches are already doing that so should be OK as 
they are.

Russell, are you able to take these through your tree (I think they 
count as consolidation work) or should I ask Stephen for a tree in 
linux-next for a while first?

Jamie
