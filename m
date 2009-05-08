From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 8 May 2009 21:07:58 +0300
Message-ID: <200905082107.59144.denys@visp.net.lb>
References: <1240495002.6554.155.camel@blade.ines.ro> <4A040625.5020609@itcare.pl> <1241805312.7242.21.camel@hazard2.francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?utf-8?q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41568 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677AbZEHSIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 14:08:16 -0400
In-Reply-To: <1241805312.7242.21.camel@hazard2.francoudi.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Btw shared L2 cache have higher latency, than dedicated one.
Thats why Core i7 rules (tested recently).

On Friday 08 May 2009 20:55:12 Vladimir Ivashchenko wrote:
> > >> It is correct, I have 2 quad-core CPUs. If adjacent
> >
> > kernel-identified
> >
> > >> CPUs are on the same physical CPU (e.g. CPU0, CPU1, CPU2 and CPU3)
> >
> > - and
> >
> > >> it is very probable - then I think the L2 cache was actually
> >
> > shared.
> >
> > >> That's because the used CPUs where either 0-3 or 4-7 but never a
> >
> > mix of
> >
> > >> them. So perhaps there is another explanation (maybe
> >
> > driver/hardware).
>
> Keep in mind that on Intel quad-core CPU cache is shared between pairs
> of cores, not for all four cores.
>
> http://www.intel.com/cd/channel/reseller/asmo-na/eng/products/desktop/proce
>ssor/processors/core2quad/feature/index.htm


