From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net/cxgb4: Avoid disabling PCI device for towice
Date: Thu, 23 Jan 2014 13:21:31 -0800 (PST)
Message-ID: <20140123.132131.259229606410755890.davem@davemloft.net>
References: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dm@chelsio.com, ben@decadent.org.uk
To: shangw@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbaAWVVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:21:32 -0500
In-Reply-To: <1390451256-11486-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <shangw@linux.vnet.ibm.com>
Date: Thu, 23 Jan 2014 12:27:34 +0800

> If we have EEH error happens to the adapter and we have to remove
> it from the system for some reasons (e.g. more than 5 EEH errors
> detected from the device in last hour), the adapter will be disabled
> for towice separately by eeh_err_detected() and remove_one(), which
> will incur following unexpected backtrace. The patch tries to avoid
> it.
 ...
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>

Applied.
