From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NMI lockup, 2.6.26 release
Date: Fri, 15 Aug 2008 16:13:59 +0300
Message-ID: <200808151614.00255.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200808131102.34988.denys@visp.net.lb> <20080813084931.GC5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.254.233.9] ([213.254.233.9]:39161 "EHLO
	relay2.globalproof.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753715AbYHONhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 09:37:35 -0400
In-Reply-To: <20080813084931.GC5367@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 August 2008, Jarek Poplawski wrote:
> I doubt current rc versions are stable enough for any production. HTB
> waits for one fix, but it's nothing critical if it didn't bothered you
> until now. There could be still some problems around schedulers
> generally, after last big changes.
>
After patching issue with locking, i apply 2.6.27-rc3 with those(locking, not 
testing patch which limits resolution) patches on shaper who was crashing on 
load. Without your patch it was crashing like before on 2.6.27-rc3 too (NMI 
watchdog issuing panic, and machine not rebooting) after few hours of 
running.

Sadly i will not be able to test on this machine anymore, because i lost 
access to it and had to change network structure. 

I will try to bring it locally to my office and simulate crash by generating 
traffic, but most probably it will not work. Seems your patch is required for 
mainline, but now i can test it only in theory, because another machine 
running as shaper now, running HPET, not TSC (it is AMD Opteron).
