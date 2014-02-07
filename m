From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Allow VF rss on higher PFs
Date: Thu, 06 Feb 2014 20:39:02 -0800 (PST)
Message-ID: <20140206.203902.2112242737667767977.davem@davemloft.net>
References: <1391609232-875-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaBGEjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 23:39:04 -0500
In-Reply-To: <1391609232-875-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Wed, 5 Feb 2014 16:07:12 +0200

> bnx2x driver uses incorrect PF identifier to configure (in HW) the VF
> interrupt scheme; As a result, in multi-function mode the configuration
> for PFs with a high index (4+) will overflow and the PF will erroneously
> configure a single ISR scheme for its VFs.
> As a result, if such a VF uses multiple queues, interrupt generation will
> stop after VF receives an Rx packet or sends a Tx packet on a queue
> other than queue[0].
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
