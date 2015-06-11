From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: handle device renames for per-device sysctls
Date: Thu, 11 Jun 2015 16:48:02 -0700 (PDT)
Message-ID: <20150611.164802.650829793758940197.davem@davemloft.net>
References: <5579A371.90101@cumulusnetworks.com>
	<1434049106-30407-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	roopa@cumulusnetworks.com, sfeldma@gmail.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703AbbFKXsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 19:48:03 -0400
In-Reply-To: <1434049106-30407-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Thu, 11 Jun 2015 19:58:26 +0100

> If a device is renamed and the original name is subsequently reused
> for a new device, the following warning is generated:
 ...
> Fix this by unregistering the previous sysctl table (registered for
> the path containing the original device name) and re-registering the
> table for the path containing the new device name.
> 
> Fixes: 37bde79979c3 ("mpls: Per-device enabling of packet input")
> Reported-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thanks Robert.
