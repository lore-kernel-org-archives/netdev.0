From: Rick Jones <rick.jones2@hp.com>
Subject: running aggregate netperf TCP_RR Re: e1000 full-duplex TCP performance
 well below wire speed
Date: Thu, 31 Jan 2008 10:11:48 -0800
Message-ID: <47A20F64.5030609@hp.com>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>	<36D9DB17C6DE9E40B059440DB8D95F52044F8BA3@orsmsx418.amr.corp.intel.com>	<47A1E553.8010006@aei.mpg.de>	<36D9DB17C6DE9E40B059440DB8D95F52044F8EC9@orsmsx418.amr.corp.intel.com> <47A204E5.7060406@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Bruce Allen <ballen@gravity.phys.uwm.edu>,
	netdev@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:28398 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761574AbYAaSLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:11:51 -0500
In-Reply-To: <47A204E5.7060406@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> PS: Am I right that the TCP_RR tests should only be run on a single node 
> at a time, not on both ends simultaneously?

It depends on what you want to measure.  In this specific case since the 
goal is to saturate the link in both directions it is unlikely you 
should need a second instance running, and if you do, going to a 
TCP_STREAM+TCP_MAERTS pair might be indicated.

If one is measuring aggregate small transaction (perhaps packet) 
performance, then there can be times when running multiple, concurrent, 
aggregate TCP_RR tests is indicated.

Also, from time to time you may want to experiment with the value you 
use with -b - the value necessary to get to saturation may not always be 
the same - particularly as you switch from link to link and from LAN to 
WAN and all those familiar bandwidthXdelay considerations.

happy benchmarking,

rick jones
