From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 20 Mar 2015 16:36:55 -0400 (EDT)
Message-ID: <20150320.163655.474336751434677390.davem@davemloft.net>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@resnulli.us, ronen.arad@intel.com,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38314 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbCTUg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:36:57 -0400
In-Reply-To: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa@cumulusnetworks.com
Date: Fri, 20 Mar 2015 09:58:34 -0700

> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
> there is a need to not re-forward frames that have already been
> forwarded in hardware.

It's impossible to validate this without seeing a use case where
the device marks packets appropriately in order to trigger this
new code.

And as John said, some devices may not even be able to do that.
