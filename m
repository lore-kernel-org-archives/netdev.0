From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] smsc911x: Remove dev==NULL check.
Date: Thu, 20 Aug 2015 14:38:39 -0700 (PDT)
Message-ID: <20150820.143839.1401698002224846672.davem@davemloft.net>
References: <1440002803-5113-1-git-send-email-jeremy.linton@arm.com>
	<1440002803-5113-3-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@linuxfoundation.org,
	steve.glendinning@shawell.net, linux@roeck-us.net
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57351 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbHTVik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:38:40 -0400
In-Reply-To: <1440002803-5113-3-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Wed, 19 Aug 2015 11:46:43 -0500

> The dev==NULL check in smsc911x_probe_config is useless
> and isn't providing any additional protection. If a fwnode
> doesn't exist then an appropriate error should be returned
> by device_get_phy_mode() covering the original case
> of a missing of/fwnode.
> 
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Applied.
