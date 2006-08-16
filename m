From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000: ethtool -p + cable pull = system wedges hard
Date: Tue, 15 Aug 2006 18:03:35 -0700
Message-ID: <44E26EE7.3000100@intel.com>
References: <200608160037.k7G0btZt002839@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27279 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1750755AbWHPBF6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 21:05:58 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200608160037.k7G0btZt002839@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
> the e1000 in netdev-2.6#upstream (7.1.9-k4).
> 
> 	Starting up "ethtool -p ethX" then unplugging the cable
> connected to the identified port is causing my system to completely
> freeze; even sysrq is unresponsive.  I'm running on a 2-way x86 box,
> with an 82545GM.
> 
> 	Is this by any chance a known problem?

not at all.

Can you include the output of `lspci -vv` and `ethtool -e ethX` ? We'll have to 
  go try to reproduce this.

It is certainly not a good thing that it hangs when you try to identify the 
port and unplug the cable, that should certainly work :)

Cheers,

Auke
