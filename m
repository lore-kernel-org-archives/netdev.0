From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix VF flr flow
Date: Tue, 21 Jan 2014 23:13:26 -0800 (PST)
Message-ID: <20140121.231326.564835234426557051.davem@davemloft.net>
References: <1390293080-21276-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbaAVHN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 02:13:27 -0500
In-Reply-To: <1390293080-21276-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Tue, 21 Jan 2014 10:31:20 +0200

> From: Ariel Elior <ariele@broadcom.com>
> 
> When a VF originating from a given PF is flr-ed, that PF gets an interrupt
> from the chip management and takes a part in the flr process.
> 
> This patch fixes several corner cases in which the driver performs its part
> of the flr flow out-of-order, causing the FW to assert due to badly timed
> messages received from the driver.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
