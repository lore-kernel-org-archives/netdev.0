From: Bruce Allen <ballen@gravity.phys.uwm.edu>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 03:59:12 -0600 (CST)
Message-ID: <Pine.LNX.4.63.0801310358300.3240@trinity.phys.uwm.edu>
References: <Pine.LNX.4.63.0801300621290.6391@trinity.phys.uwm.edu>
 <36D9DB17C6DE9E40B059440DB8D95F52044F81DF@orsmsx418.amr.corp.intel.com>
 <Pine.LNX.4.63.0801301635470.19938@trinity.phys.uwm.edu> <p738x265p7p.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	Bruce Allen <bruce.allen@aei.mpg.de>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from trinity.phys.uwm.edu ([129.89.57.159]:45422 "EHLO
	trinity.phys.uwm.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732AbYAaJ73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 04:59:29 -0500
In-Reply-To: <p738x265p7p.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andi!

>> Important note: we ARE able to get full duplex wire speed (over 900
>> Mb/s simulaneously in both directions) using UDP.  The problems occur
>> only with TCP connections.
>
> Another issue with full duplex TCP not mentioned yet is that if TSO is used
> the output  will be somewhat bursty and might cause problems with the
> TCP ACK clock of the other direction because the ACKs would need
> to squeeze in between full TSO bursts.
>
> You could try disabling TSO with ethtool.

Noted.  We'll try this also.

Cheers,
 	Bruce
