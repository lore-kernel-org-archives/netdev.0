From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Tue, 1 Apr 2003 09:47:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D30D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>,
   Jason Lunz
	 <lunz@falooley.org>
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> A better approximation I think but probably not the last...

Thanks for you help guys!  I broke NAPI (don't hate me) and then went on
vacation, so I apologize for not responding sooner.  I like what you've
come up with here, so I'll turn the patch around for Jeff to update 2.5
e1000.

> +       e1000_clean_tx_irq(adapter);
> +       e1000_clean_rx_irq(adapter, &work_done, work_to_do);

Just curious, why give priority to Tx over Rx?

-scott
