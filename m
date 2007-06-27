From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] Update MAINTAINERS for USB network devices
Date: Wed, 27 Jun 2007 21:18:18 +0200
Message-ID: <877ippgq9x.fsf@p4.be.48ers.dk>
References: <87myyl6df1.fsf@nanv.dk> <46821E80.8080105@garzik.org>
	<200706270154.16022.david-b@pacbell.net>
	<20070627144416.GA28899@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Brownell <david-b@pacbell.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Petko Manolov <petkan@nucleusys.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:29741 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbXF0TSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 15:18:05 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id C85B170000A0
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 21:17:59 +0200 (CEST)
In-Reply-To: <20070627144416.GA28899@kroah.com> (Greg KH's message of "Wed, 27
	Jun 2007 07:44:16 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Greg" == Greg KH <greg@kroah.com> writes:

 Greg> Yeah, this is the cdc_acm driver that is still in the USB drivers/
 Greg> directory tree as it is a USB class driver that shows up as a tty device
 Greg> to userspace.  It should not be moved to the networking list unless no
 Greg> one minds that I never see any queries about it :)

Ok, here's an updated patch:

Questions regarding the USB network drivers should now go to netdev.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
Acked-by: David Brownell <dbrownell@users.sourceforge.net>

---
 MAINTAINERS |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: linux-2.6.22-rc6/MAINTAINERS
===================================================================
--- linux-2.6.22-rc6.orig/MAINTAINERS
+++ linux-2.6.22-rc6/MAINTAINERS
@@ -3618,7 +3618,7 @@
 USB DAVICOM DM9601 DRIVER
 P:	Peter Korsgaard
 M:	jacmet@sunsite.dk
-L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
 
@@ -3702,8 +3702,8 @@
 USB PEGASUS DRIVER
 P:	Petko Manolov
 M:	petkan@users.sourceforge.net
-L:	linux-usb-users@lists.sourceforge.net
 L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://pegasus2.sourceforge.net/
 S:	Maintained
 
@@ -3717,8 +3717,8 @@
 USB RTL8150 DRIVER
 P:	Petko Manolov
 M:	petkan@users.sourceforge.net
-L:	linux-usb-users@lists.sourceforge.net
 L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://pegasus2.sourceforge.net/
 S:	Maintained
 
@@ -3829,7 +3829,7 @@
 USB "USBNET" DRIVER FRAMEWORK
 P:	David Brownell
 M:	dbrownell@users.sourceforge.net
-L:	linux-usb-devel@lists.sourceforge.net
+L:	netdev@vger.kernel.org
 W:	http://www.linux-usb.org/usbnet
 S:	Maintained
 


-- 
Bye, Peter Korsgaard

