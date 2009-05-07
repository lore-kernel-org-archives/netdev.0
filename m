From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [PATCH 1/2] igb: Implement reading of reg RQDPC (Receive Queue
	Drop Packet Count)
Date: Thu, 7 May 2009 10:06:45 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365F7744D662@rrsmsx501.amr.corp.intel.com>
References: <1241703346.18487.22.camel@localhost.localdomain>
 <1241703431.18487.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55150 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZEGQGs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 12:06:48 -0400
In-Reply-To: <1241703431.18487.25.camel@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>-----Original Message-----
>From: netdev-owner@vger.kernel.org 
>[mailto:netdev-owner@vger.kernel.org] On Behalf Of Jesper 
>Dangaard Brouer
>Sent: Thursday, May 07, 2009 6:37 AM
>To: Kirsher, Jeffrey T
>Cc: David S. Miller; netdev@vger.kernel.org; 
>e1000-devel@lists.sourceforge.net; Ronciak, John; Waskiewicz 
>Jr, Peter P
>Subject: [PATCH 1/2] igb: Implement reading of reg RQDPC 
>(Receive Queue Drop Packet Count)
>
>
>Implement reading the per queue drop stats register
>RQDPC (Receive Queue Drop Packet Count).  It counts the number of
>packets dropped by a queue due to lack of descriptors available.
>
>Notice RQDPC (Receive Queue Drop Packet Count) stats only gets
>incremented, if the DROP_EN bit it set (in the SRRCTL register
>for that queue). If DROP_EN bit is NOT set, then the some what
>equivalent count is stored in RNBC (not per queue basis).
>
>The RQDPC register is only 12 bit, thus the precision might
>suffer due to overrun in-between the watchdog polling interval.

NAK.  82575 doesn't have RQDPC registers.  You need to check
which part you're running on before you read those registers.

Other than that, this looks OK to me.

-Mitch