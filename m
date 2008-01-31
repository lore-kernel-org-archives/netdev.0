From: Bill Fink <billfink@mindspring.com>
Subject: Re: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 12:36:27 -0500
Message-ID: <20080131123627.599be68f.billfink@mindspring.com>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu>
	<20080130.055333.192844925.davem@davemloft.net>
	<Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu>
	<20080130082136.1017631d@deepthought>
	<Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu>
	<649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com>
	<20080131064533.ef0ae932.billfink@mindspring.com>
	<Pine.LNX.4.63.0801310951060.10967@trinity.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: SANGTAE HA <sangtae.ha@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Bruce Allen <ballen@gravity.phys.uwm.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:58981 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbYAaRge (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:36:34 -0500
In-Reply-To: <Pine.LNX.4.63.0801310951060.10967@trinity.phys.uwm.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bruce,

On Thu, 31 Jan 2008, Bruce Allen wrote:

> > I see similar results on my test systems
> 
> Thanks for this report and for confirming our observations.  Could you 
> please confirm that a single-port bidrectional UDP link runs at wire 
> speed?  This helps to localize the problem to the TCP stack or interaction 
> of the TCP stack with the e1000 driver and hardware.

Yes, a single-port bidirectional UDP test gets full GigE line rate
in both directions with no packet loss.

[bill@chance4 ~]$ nuttcp -f-beta -Itx -u -Ru -w2m 192.168.6.79 & nuttcp -f-beta -Irx -r -u -Ru -w2m 192.168.6.79
tx:  1187.0078 MB /  10.04 sec =  992.0550 Mbps 19 %TX 7 %RX 0 / 151937 drop/pkt 0.00 %loss
rx:  1187.1016 MB /  10.03 sec =  992.3408 Mbps 19 %TX 7 %RX 0 / 151949 drop/pkt 0.00 %loss

						-Bill
