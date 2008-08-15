From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: NMI lockup, 2.6.26 release
Date: Fri, 15 Aug 2008 16:16:06 +0200
Message-ID: <20080815141606.GA2916@ami.dom.local>
References: <200807222142.23710.denys@visp.net.lb> <200808131102.34988.denys@visp.net.lb> <20080813084931.GC5367@ff.dom.local> <200808151614.00255.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.181]:36895 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbYHOOOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 10:14:18 -0400
Received: by ik-out-1112.google.com with SMTP id c28so1007732ika.5
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2008 07:14:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808151614.00255.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 15, 2008 at 04:13:59PM +0300, Denys Fedoryshchenko wrote:
...
> After patching issue with locking, i apply 2.6.27-rc3 with those(locking, not 
> testing patch which limits resolution) patches on shaper who was crashing on 
> load. Without your patch it was crashing like before on 2.6.27-rc3 too (NMI 
> watchdog issuing panic, and machine not rebooting) after few hours of 
> running.
> 
> Sadly i will not be able to test on this machine anymore, because i lost 
> access to it and had to change network structure. 
> 
> I will try to bring it locally to my office and simulate crash by generating 
> traffic, but most probably it will not work. Seems your patch is required for 
> mainline, but now i can test it only in theory, because another machine 
> running as shaper now, running HPET, not TSC (it is AMD Opteron).

Since this bug looks so rare, probably hardware dependent, it looks
like fixing this can wait until it bothers somebody again. The most
important, some workaround has been found, and we can go back to
to improve this.

Thanks,
Jarek P.
