From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Regarding NAPI performance
Date: Tue, 27 Apr 2004 09:54:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16526.4532.22789.626062@robur.slu.se>
References: <20040426184039.91977.qmail@web60210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: prashant s <sree_prash@yahoo.com>
In-Reply-To: <20040426184039.91977.qmail@web60210.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


prashant s writes:

 > driver without NAPI (rtl8139too in 2.4.20 linux)
 > showed 72Mbps and the NAPI driver (rtl8139too in
 > 2.6.3) showed 94Mbps,both having their ring size at
 > 8k.The packet size i used was same as before.
 > why is this difference when the ring size is reduced.

 Well a good question. I would expect non-NAPI to perform
 equal to NAPI at low network load even w. small RX-rings.
 
 Any difference interrupt delay? NAPI can live without 
 delay. Or some other driver difference? I have no experience 
 with rtl8139too myself.

 Cheers.
					--ro
 
 
