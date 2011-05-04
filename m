From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] tcp_cubic: limit delayed_ack ratio to prevent divide
 error
Date: Wed, 4 May 2011 13:53:51 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.1105041352020.6048@JBRANDEB-DESK2.amr.corp.intel.com>
References: <20110504113351.4643a0c9@nehalam> <16668.1304537481@localhost> <20110504123738.7bb4d1ee@nehalam> <20110504.124053.260068550.davem@davemloft.net> <20110504130456.425dee68@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Injong Rhee <injongrhee@gmail.com>,
	"Valdis.Kletnieks@vt.edu" <Valdis.Kletnieks@vt.edu>,
	"rdunlap@xenotime.net" <rdunlap@xenotime.net>,
	"lkml@techboom.com" <lkml@techboom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45538 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756004Ab1EDUx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 16:53:59 -0400
In-Reply-To: <20110504130456.425dee68@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 4 May 2011, Stephen Hemminger wrote:

> TCP Cubic keeps a metric that estimates the amount of delayed
> acknowledgements to use in adjusting the window. If an abnormally
> large number of packets are acknowledged at once, then the update
> could wrap and reach zero. This kind of ACK could only
> happen when there was a large window and huge number of
> ACK's were lost.
> 
> This patch limits the value of delayed ack ratio. The choice of 32
> is just a conservative value since normally it should be range of 
> 1 to 4 packets.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

patch seems fine, but please credit the reporter (lkml@techboom.com) with 
reporting the issue with logs, maybe even with Reported-by: and some kind 
of reference to the panic message or the email thread in the text or 
header?

