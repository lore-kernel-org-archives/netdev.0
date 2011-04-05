From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCHv2 0/9] macb: add support for Cadence GEM
Date: Tue, 5 Apr 2011 13:21:02 +0200
Message-ID: <20110405112102.GB19268@game.jcrosoft.org>
References: <20110316.131734.242138246.davem@davemloft.net>
 <4D86F25A.7060405@atmel.com>
 <20110321111838.GC2610@pulham.picochip.com>
 <20110322161811.GF6466@game.jcrosoft.org>
 <20110322163917.GD10058@pulham.picochip.com>
 <20110322175523.GE10058@pulham.picochip.com>
 <20110324162517.GI6466@game.jcrosoft.org>
 <20110331094041.GD3371@pulham.picochip.com>
 <20110405102842.GC22192@game.jcrosoft.org>
 <20110405104910.GE4797@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	David Miller <davem@davemloft.net>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Andrew Victor <linux@maxim.org.za>,
	linux-arm-kernel@lists.infradead.org
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 63.mail-out.ovh.net ([91.121.185.56]:43502 "HELO
	63.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753138Ab1DEL2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 07:28:43 -0400
Content-Disposition: inline
In-Reply-To: <20110405104910.GE4797@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11:49 Tue 05 Apr     , Jamie Iles wrote:
> On Tue, Apr 05, 2011 at 12:28:42PM +0200, Jean-Christophe PLAGNIOL-VILLARD wrote:
> > work fine on 9263ek except the IP version detection.
> > 
> > the at91 macb ip version is supposed to be at 0x0601010C but it's not.
> > At least on 9263 it's 0x0001010C. So we can not detect the arch at runtime
> > but we can detect that it's a macb.
> > 
> > So could keep the ifdef for 2 archs but use the ip version on arm
> 
> OK, well I think my patches are already doing that so should be OK as 
> they are.
> 
> Russell, are you able to take these through your tree (I think they 
> count as consolidation work) or should I ask Stephen for a tree in 
> linux-next for a while first?
no please do not us the is_gem but the same way as I did in the ip detection
keep the version register and then check it.

as this ip can be used on other arch we do not want to see thousands of is_xxx

Best Regards,
J.
