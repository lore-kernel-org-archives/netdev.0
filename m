From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: bna: PCI Probe Fix
Date: Tue, 20 Sep 2011 11:47:21 +0300
Message-ID: <20110920084721.GA8441@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:21400 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab1ITIre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 04:47:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rasesh,

There is a problem introduced in 0caa9aaec5 "bna: PCI Probe Fix".

If register_netdev() fails now, then we call mutex_unlock(&bnad->conf_mutex);
on the error path, but it's already unlocked.

regards,
dan carpenter
