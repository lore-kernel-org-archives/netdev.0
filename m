From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 13:22:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D318@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jason Lunz
	 <lunz@falooley.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Just curious, why give priority to Tx over Rx?
> 
> TX frees skbs, RX allocates skbs.
> 
> You lessen the chance of allocation failure or "additional 
> work" being performed by the allocator when you do it in this order.

At the expense of Rx latency.  I suppose the best would be:

rx_clean
tx_clean
rx_alloc

-scott
