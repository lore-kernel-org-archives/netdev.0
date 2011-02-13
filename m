From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] net: dcb: application priority is per
 net_device
Date: Sun, 13 Feb 2011 11:03:11 -0800 (PST)
Message-ID: <20110213.110311.241916087.davem@davemloft.net>
References: <20110131220048.29758.22379.stgit@jf-dev1-dcblab>
	<20110131220059.29758.17857.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41239
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754780Ab1BMTCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 14:02:35 -0500
In-Reply-To: <20110131220059.29758.17857.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 31 Jan 2011 14:00:59 -0800

> The app_data priority may not be the same for all net devices.
> In order for stacks with application notifiers to identify the
> specific net device dcb_app_type should be passed in the ptr.
> 
> This allows handlers to use dev_get_by_name() to pin priority
> to net devices.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
