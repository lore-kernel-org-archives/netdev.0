From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Why was the /proc info removed from e1000 ?
Date: Thu, 30 Jan 2003 08:26:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E01087BE9@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
content-class: urn:content-classes:message
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I just noticed in the latest changelog that the /proc
> support was removed from the e1000 driver?  I always
> found this usefull...any reason why it was deleted?

Because the information that was exported to /proc is available through
standard interfaces such as ethtool, pciutils, etc.  

ethtool -i eth<x> associates eth<x> with PCI bus:dev.func, so you should
be able to find what you need starting there.  Also note that ethtool -S
support was added for netdev stats.

If you find something missing, let's talk about an alternative.

-scott
