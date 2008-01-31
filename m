From: Andi Kleen <andi@firstfloor.org>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:17:14 +0100
Message-ID: <p738x265p7p.fsf@bingen.suse.de>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
	<36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
	<Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:38651 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751121AbYAaJRQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 04:17:16 -0500
In-Reply-To: <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> (Bruce Allen's message of "Wed\, 30 Jan 2008 17\:07\:28 -0600 \(CST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bruce Allen <ballen@gravity.phys.uwm.edu> writes:
>
> Important note: we ARE able to get full duplex wire speed (over 900
> Mb/s simulaneously in both directions) using UDP.  The problems occur
> only with TCP connections.

Another issue with full duplex TCP not mentioned yet is that if TSO is used 
the output  will be somewhat bursty and might cause problems with the 
TCP ACK clock of the other direction because the ACKs would need 
to squeeze in between full TSO bursts.

You could try disabling TSO with ethtool.

-Andi
