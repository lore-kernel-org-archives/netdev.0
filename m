From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH] fix use after free in e100
Date: Tue, 3 Jun 2003 13:01:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D862@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Martin Josefsson" <gandalf@wlug.westbo.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Here's a fix for a use-after-free in the e100 driver.
> You can't touch the skb after a call to netif_rx(), it might 
> have been free'd. Caught with Manfred's unmap-page-debugging 
> patch in -mm.

Thanks Martin.  We'll pick this patch up in our dev driver and propagate
the change from there.

-scott
