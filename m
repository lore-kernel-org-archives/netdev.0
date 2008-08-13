From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: NMI lockup, 2.6.26 release
Date: Wed, 13 Aug 2008 12:08:23 +0300
Message-ID: <200808131208.23284.denys@visp.net.lb>
References: <200807222142.23710.denys@visp.net.lb> <200808131102.34988.denys@visp.net.lb> <20080813084931.GC5367@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:42855 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbYHMJJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:09:23 -0400
In-Reply-To: <20080813084931.GC5367@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 August 2008, Jarek Poplawski wrote:
> I don't think it's right: there could be probably some small time
> differences between cpus on SMP or even some inaccuracy related to
> hardware, but I don't think it's the right place or method to verify
> this. And eg. re-scheduling with the same time shouldn't be wrong too.
OK! Got you. 
Difference possible, on that machine it is using TSC from Core 2 Duo.
I tried to run some code from Ingo Molnar to check is TSC synchronised - after 
2 days it doesn't detect anything.

>
> Anyway, narrowing the problem with such tests should give us better
> understanding what could be a real problem here. BTW, could you
> "remind" us the .config on this box (especially various *HZ*, *TIME*
> and *TIMERS* settings).
http://www.nuclearcat.com/files/config_2.6.26.2.txt
Same used for 2.6.26.2, this config from 2.6.26.1

