From: Andi Kleen <ak@suse.de>
Subject: 2.6.24 regression: reference count leak in PPPoE
Date: Sun, 20 Jan 2008 20:53:30 +0100
Message-ID: <200801202053.30386.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:51129 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbYATTxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jan 2008 14:53:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


My workstation running 2.6.24-rc8 just hung during shutdown with an endless 
(or rather I didn't wait more than a few minutes) loop of 

unregister_netdev: waiting for ppp-device to become free. Usage count = 1

ppp-device was an active PPPoE device.

No more information currently.

-Andi
