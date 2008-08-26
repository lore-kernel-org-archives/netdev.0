From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Wed, 27 Aug 2008 00:14:07 +0400
Message-ID: <20080826201406.GA24827@2ka.mipt.ru>
References: <200808220457.40892.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55950 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbYHZUOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 16:14:25 -0400
Content-Disposition: inline
In-Reply-To: <200808220457.40892.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2008 at 04:57:40AM +0300, Denys Fedoryshchenko (denys@visp.net.lb) wrote:
> I have loaded router (~650 Mbps In+Out), based on 2xAMD Opteron 248, Sun Fire 
> X4100. HPET timer available (TSC seems not available on this platform).
> Network interfaces is onboard, connected over PCI-X.
> 
> Right now i am using only one processor, cause using only one interface and 
> interrupts stick to it. Other is almost not used.
> At peak time i notice in mpstat, that this processor is almost "dead", and if 
> i run minor application consuming resources - ping over this router will be 
> terrible. For me it is clear - system overloaded. I did oprofile, and here is 
> result (at low load time, but at peak time it is very similar).

Do you have any packet sockets in this system? Like running dhcp daemon?

-- 
	Evgeniy Polyakov
