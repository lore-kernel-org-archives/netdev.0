From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [2/4] pollcontroller patch for 2.6.0-test10-bk25-netdrvr-exp1
Date: Fri, 5 Dec 2003 14:06:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229B1A@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <mpm@selenic.com>, <suparna@in.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Feldman, Scott" <scott.feldman@intel.com>,
        "Jeff Garzik" <jgarzik@pobox.com>, <prasanna@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Additionally, if you have VLANs enabled on the interface, we 
> might need to care about netif_hwaccell_[rx|receive_skb].  
> Something tells me all of the netif_* receive funcs need to 
> handle the netdump conversation. That would be easier than 
> special casing poll_controller in each driver. Is someone 
> working on this?

Ok, nevermind, we looked closer at lkcd/netpoll patches and it looks
like this is addressed.

-scott
