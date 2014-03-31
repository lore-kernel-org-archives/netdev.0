From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: move Novatel E371 (1410:9011) to
 qmi_wwan
Date: Mon, 31 Mar 2014 16:06:27 -0400 (EDT)
Message-ID: <20140331.160627.41049785170860974.davem@davemloft.net>
References: <1396004838-23877-1-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjorn@mork.no, dcbw@redhat.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42590 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbaCaUG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:06:29 -0400
In-Reply-To: <1396004838-23877-1-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yegorslists@googlemail.com
Date: Fri, 28 Mar 2014 12:07:18 +0100

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> This device provides QMI and ethernet functionality via a standard CDC
> ethernet descriptor.  But when driven by cdc_ether, the QMI
> functionality is unavailable because only cdc_ether can claim the USB
> interface. Thus blacklist the device in cdc_ether and add its IDs to
> qmi_wwan, which enables both QMI and ethernet simultaneously.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

Applied, thank you.
