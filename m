From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH 2.5.70] e100 initialize fields prior to register_netdevice
Date: Thu, 29 May 2003 15:45:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010107D800@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>,
   "Stephen Hemminger" <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Agreed.  I consider this a rather serious bug, that could 
> cause crashes in multiple corner cases; sysfs being only 
> one of those cases.
> 
> I'm going to go ahead and apply this to 2.5.
> 
> Stephen, could I get you to send me a similar patch for 2.4? 
> (it doesn't apply cleanly)  It's very much a bug in 2.4 also.

2.4 e100 should be fine, as this breakage was just introduced in last
patchset for 2.5 (only).

Thanks Stephen.

-scott
