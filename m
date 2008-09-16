From: David Miller <davem@davemloft.net>
Subject: btusb suspend/resume bug...
Date: Tue, 16 Sep 2008 15:51:23 -0700 (PDT)
Message-ID: <20080916.155123.181085856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59720
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750915AbYIPWv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 18:51:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Marcel, others, please bring some kind of closure to this
regression list entry:

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=11442
Subject		: btusb hibernation/suspend breakage in current -git
Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
Date		: 2008-08-25 11:37 (19 days old)
References	: http://marc.info/?l=linux-bluetooth&m=121966402012074&w=4
Handled-By	: Oliver Neukum <oliver@neukum.org>
Patch		: http://marc.info/?l=linux-bluetooth&m=121967226027323&w=4

There is a patch, it is tested, so the only course of action at
this point is to merge the fix or declare that this really isn't
a regression.

My impression is the later, because the driver btusb is replacing
doesn't handle suspend/resume either.  Isn't that right?
