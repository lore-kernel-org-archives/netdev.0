From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 1 Feb 2008 22:47:39 +0100
Message-ID: <20080201214738.GA3071@ami.dom.local>
References: <47A2540D.8090003@gmail.com> <20080201074239.GA2897@ff.dom.local> <D5C1322C3E673F459512FB59E0DDC32904737A40@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:5270 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbYBAVol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 16:44:41 -0500
Received: by ug-out-1314.google.com with SMTP id z38so821662ugc.16
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 13:44:39 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32904737A40@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 01, 2008 at 01:28:15AM -0800, Waskiewicz Jr, Peter P wrote:
...
> The TCP layer will generate TSO packets based on the kernel socket
> features associated with the flow.  So if you have two devices, one
> supporting TSO, the other not, then the flows associated with the
> non-TSO device will not have their packets built for TSO.  This has no
> bearing on the device supporting TSO, which its feature flags will
> propogate into the kernel socket for that flow, and cause any TCP flows
> to that device to be TSO packets.  So in a nutshell, disabling TSO is on
> a per-device level, not a global switch.

Fine, but I was rather wondering if there could be something more in
the idea of this patch that can't be done with ethtool. And I don't
think qdisc code currently treats or should treat TCP special.

Jarek P.
