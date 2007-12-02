From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Inconsistent lock  state and possible irq lock inversion dependency
 detected in ax25.ko
Date: Sun, 02 Dec 2007 23:02:08 +0100
Message-ID: <47532B60.8030205@o2.pl>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru> <4744AD8B.2000908@ccr.jussieu.fr> <4752ED3D.2060204@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:53009 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750942AbXLBV4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2007 16:56:19 -0500
In-Reply-To: <4752ED3D.2060204@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernard Pidoux wrote, On 12/02/2007 06:37 PM:

> Hi,
> 
> Many thanks for your patch for ~/net/ax25/ax25_subr.c
> 
> Introduction of local_bh_disable() ... local_bh_enable()
> 
> cured the inconsistent lock state related to AX25 connect timeout.
> 
> I have now a stable monoprocessor system running AX25 and ROSE network 
> packet switching application FPAC, whether kernel is compiled with or 
> without hack option.
> 
> There is no more problem during normal operations.
> 
> This was achieved, thanks to your AX25 patch and the patch from Alexey 
> Dobriyan for rose module.
> 
> I also patched rose module in order to get packet routing more 
> efficient, taking into account the "restarted" flag that is raised when 
> a neighbour node is already connected.
> 
> To summarize the present situation on my Linux machine, I built a patch 
> against kernel 2.6.23.9.
> 
> I would appreciate if you could make it included into a next kernel release.
... 

Bernard, I'm very glad I could be a little helpful, but I'm not sure of
your intentions: my patch proposal is rather trivial interpretation of
lockdep's report; I haven't studied AX25 enough even to be sure there is
a real lockup possible in this place. Since this change looks not very
costly and quite safe, I can 'take a risk' to sign this off after your
testing. But anything more is beyond my 'range'.

So, since you've spent quite a lot of time on this all, maybe it would
be simpler if you've tried the same with the current kernel, and resent
"proper" (not gzipped and with changelog) patch or patches. Then, I hope,
Ralf, as the maintainer, will make the rest.

Regards,
Jarek P.
