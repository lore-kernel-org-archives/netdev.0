From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] bridge: Add fdb dst check during fdb update
Date: Mon, 29 Apr 2013 11:41:11 -0400 (EDT)
Message-ID: <20130429.114111.200161303297538854.davem@davemloft.net>
References: <1365968593-28725-1-git-send-email-roopa@cumulusnetworks.com>
	<20130422155649.2e4aebcf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org,
	nolan@cumulusnetworks.com, shm@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809Ab3D2PlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:41:14 -0400
In-Reply-To: <20130422155649.2e4aebcf@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 22 Apr 2013 15:56:49 -0700

> From: roopa <roopa@cumulusnetworks.com>
> 
> Current bridge fdb update code does not seem to update the port
> during fdb update. This patch adds a check for fdb dst (port)
> change during fdb update. Also rearranges the call to
> fdb_notify to send only one notification for create and update.
> 
> Changelog:
> v2 - Change notify flag to bool
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
