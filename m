From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] IPv6: Update documentation for better built-in help
 with params
Date: Mon, 25 Jan 2010 13:43:01 -0800
Message-ID: <20100125134301.e4849520.rdunlap@xenotime.net>
References: <4B5DD4AF.8050800@hp.com>
	<20100125.132142.144428296.davem@davemloft.net>
	<20100125133133.aa2b86a2.rdunlap@xenotime.net>
	<20100125.133411.191160829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, greg@enjellic.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([72.52.64.118]:52243 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753724Ab0AYVnD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 16:43:03 -0500
Received: from chimera.site ([96.253.169.185]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 13:43:01 -0800
In-Reply-To: <20100125.133411.191160829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Jan 2010 13:34:11 -0800 (PST) David Miller wrote:

> From: Randy Dunlap <rdunlap@xenotime.net>
> Date: Mon, 25 Jan 2010 13:31:33 -0800
> 
> > On Mon, 25 Jan 2010 13:21:42 -0800 (PST) David Miller wrote:
> > 
> >> From: Brian Haley <brian.haley@hp.com>
> >> Date: Mon, 25 Jan 2010 12:28:15 -0500
> >> 
> >> > I guess Documentation/kernel-parameters.txt is where such things
> >> > live, can I send you a patch for that or does it need to go
> >> > through someone else?
> >> 
> >> I think lkml is a suitable place to submit something like
> >> that.
> >> --
> > 
> > Sure, but if it's networking parameters, you (David) could still merge it...
> 
> It's not about networking parameters.

OK, I didn't see the patch itself, sorry.


> It's about adding a generic mention somewhere central that you can set
> "module parameters" on the kernel command line when a module is built
> statically into the kernel.

Maybe like this, from that same file:

Module parameters for modules that are built into the kernel image
are specified on the kernel command line with the module name plus
'.' plus parameter name, with '=' and value if appropriate, such as:

	usbcore.blinkenlights=1



I'll search for the patch...

---
~Randy
