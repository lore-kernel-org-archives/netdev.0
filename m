From: Jeff Garzik <jgarzik@pobox.com>
Subject: [ANN] removal of certain net drivers coming soon: eepro100, xircom_tulip_cb,
 iph5526
Date: Thu, 27 Jan 2005 15:45:40 -0500
Message-ID: <41F952F4.7040804@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(GregKH cc'd for his deprecated list)

Though this has already been mentioned, I thought I would send out a 
reminder.  The following net drivers are slated for removal "soon", in 
the next kernel version or so:


1) iphase (iph5526 a.k.a. drivers/net/fc/*)

Been broken since 2.3 or 2.4.  Only janitors have kept it compiling.


2) xircom_tulip_cb

Unmaintained, and does not work for all xircom 32bit cards.  xircom_cb, 
on the other hand, works for ALL xircom 32bit cards.


3) eepro100

Unmaintained; users should use e100.

When I last mentioned eepro100 was going away, I got a few private 
emails saying complaining about issues not yet taken care of in e100. 
eepro100 will not be removed until these issues are resolved.
