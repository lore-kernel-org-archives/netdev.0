From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/2] myri10ge fixes
Date: Sun, 30 Jul 2006 00:14:04 -0400
Message-ID: <44CC320C.1090203@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:62442 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751091AbWG3EO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 00:14:27 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following 2 patches fix the following issues in the myri10ge driver:

#1 - When writing the firmware to the NIC, the FIFO is 256-bytes long,
so we use 256-bytes chunks and a read to wait until the previous write
is done.
I sent this patch two weeks ago, this new version removes the
superfluous second mb().
#2 - Fix spurious invocations of the watchdog reset handler.

Please apply,

Thanks,
Brice Goglin

