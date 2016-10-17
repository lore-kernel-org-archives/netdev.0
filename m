From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: Kernel 4.6.7-rt13: Intel Ethernet driver igb causes huge
 latencies in cyclictest
Date: Mon, 17 Oct 2016 21:03:34 +0200
Message-ID: <20161017190334.GA19627@netboy>
References: <13c3cd3ffee4490fb22b8de383e51361@FE-MBX1012.de.bosch.com>
 <AAEA33E297BCAC4B9BB20A7C2DF0AB8D8045E418@FMSMSX113.amr.corp.intel.com>
 <29250f87b1d84aacb8aa312935582291@FE-MBX1012.de.bosch.com>
 <20161010193958.GE22235@jcartwri.amer.corp.natinst.com>
 <e9661abf93194ad3849e3864a8361993@FE-MBX1012.de.bosch.com>
 <b77ea8ab312149d2b20a717d3ab0a8dc@FE-MBX1012.de.bosch.com>
 <20161013161839.GV10625@jcartwri.amer.corp.natinst.com>
 <f395ea6cd1274fac83d2744121da7441@FE-MBX1012.de.bosch.com>
 <20161014220633.GA1811@netboy>
 <20161017183645.GA9435@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "linux-rt-users@vger.kernel.org" <linux-rt-users@vger.kernel.org>,
        Sebastian Andrzej Siewior <sebastian.siewior@linutronix.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        Greg <gvrose8192@gmail.com>
To: Julia Cartwright <julia@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:34771 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934954AbcJQTDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:03:39 -0400
Content-Disposition: inline
In-Reply-To: <20161017183645.GA9435@jcartwri.amer.corp.natinst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 01:36:45PM -0500, Julia Cartwright wrote:
> While that is certainly the case, and would explain the most egregious
> of measured latency spikes, it doesn't invalidate the test if you
> consider the valuable data point(s) to be the minimum and/or median
> latencies.

Well, consider the case where an interrupt is stuck on.  That is a
possible cause, and it can be positively excluded by either disabling
local interrupts around the time stamps or by putting the vector
events into the trace.

(Doesn't matter now that bisection fingered the PCIe setup, just sayin.)

Thanks,
Richard
