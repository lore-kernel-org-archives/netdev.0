From: "Chris Snook" <csnook@redhat.com>
Subject: [PATCH 0/3] remove =?UTF-8?Q?irq=5Fsem=20cruft=20from=20e=31=30=30=30=20a?=
 =?UTF-8?Q?nd=20derivatives?=
Date: Mon, 19 Feb 2007 19:57:05 -0500
Message-ID: <20070220.Bq5.44322700@egw.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, jacliburn@bellsouth.net, csnook@redhat.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965840AbXBTA5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 19:57:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey folks --

     While digging through the atl1 source, I was troubled by the code using
irq_sem.  I did some digging and found the same code in e1000 and ixgb.  I'm
not entirely sure what it was originally intended to do, but it doesn't seem
to be doing anything useful now, except possibly locking interrupts off if
NAPI is flipped on and off enough times to cause an integer overflow.

     The following patches completely remove irq_sem from each of the drivers.
 This has been tested successfully on atl1 and e1000.  If someone would like
to send me ixgb hardware I'd be glad to test that, otherwise you'll have to
test it yourself. :)

     -- Chris

