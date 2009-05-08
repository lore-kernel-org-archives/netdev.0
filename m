From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: htb parallelism on multi-core platforms
Date: Fri, 08 May 2009 20:55:12 +0300
Message-ID: <1241805312.7242.21.camel@hazard2.francoudi.com>
References: <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
	 <1241000494.6554.307.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
	 <1241003006.6554.322.camel@blade.ines.ro>
	 <20090429122312.GA2759@ami.dom.local>
	 <1241010951.6554.355.camel@blade.ines.ro>
	 <20090429133810.GB2759@ami.dom.local>
	 <1241022071.6554.375.camel@blade.ines.ro>
	 <395864833.20090430014946@gemenii.ro>
	 <1241090376.6554.404.camel@blade.ines.ro>
	 <747455005.20090430170426@gemenii.ro>  <4A040625.5020609@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:4673 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbZEHRzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 13:55:17 -0400
In-Reply-To: <4A040625.5020609@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> >> It is correct, I have 2 quad-core CPUs. If adjacent
> kernel-identified
> >> CPUs are on the same physical CPU (e.g. CPU0, CPU1, CPU2 and CPU3)
> - and
> >> it is very probable - then I think the L2 cache was actually
> shared.
> >> That's because the used CPUs where either 0-3 or 4-7 but never a
> mix of
> >> them. So perhaps there is another explanation (maybe
> driver/hardware).

Keep in mind that on Intel quad-core CPU cache is shared between pairs
of cores, not for all four cores.

http://www.intel.com/cd/channel/reseller/asmo-na/eng/products/desktop/processor/processors/core2quad/feature/index.htm

-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


