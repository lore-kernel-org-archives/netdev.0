From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH] Net device error logging, revised
Date: Tue, 16 Sep 2003 19:06:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010124F051@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "David Brownell" <david-b@pacbell.net>,
   "Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "Jim Keniston" <jkenisto@us.ibm.com>,
   "LKML" <linux-kernel@vger.kernel.org>, "netdev" <netdev@oss.sgi.com>,
   "Jeff Garzik" <jgarzik@pobox.com>, "Larry Kessler" <kessler@us.ibm.com>,
   "Greg KH" <greg@kroah.com>, "Randy Dunlap" <rddunlap@osdl.org>,
   "Alan Cox" <alan@lxorguk.ukuu.org.uk>, "Andrew Morton" <akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 3. A new macro, netdev_fatal, is included.  Given the call
>         netdev_fatal(dev, HW, "NIC fried!\n");
> the indicated message is always logged: the msglevel arg (HW, in this
> case) is NOT consulted.  In fact, the msglevel arg to netdev_fatal
> is ignored in this implementation.  (As previously discussed, in some
> future implementation, the msglevel could be logged to help indicate
> the circumstances under which the event was logged.)

I couldn't find the previous discussion on netdev_fatal, so sorry if
this has already been worked out.  It uses KERN_ERR; did you mean
something stronger?  If not, why not just use netdev_err(dev, ALL,
"...")?  What is the situation in the driver where we'd want to use
_fatal?  How do I know when to use _fatal and when to use _err?

-scott
