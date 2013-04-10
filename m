From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Prevent null pointer dereference in AFEX
 mode
Date: Wed, 10 Apr 2013 15:27:29 -0400 (EDT)
Message-ID: <20130410.152729.217349451145514475.davem@davemloft.net>
References: <1365590079-7422-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759513Ab3DJT1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 15:27:31 -0400
In-Reply-To: <1365590079-7422-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 10 Apr 2013 13:34:39 +0300

> The cnic module is responsible for initializing various bnx2x structs
> via callbacks provided by the bnx2x module.
> One such struct is the queue object for the FCoE queue.
> 
> If a device is working in AFEX mode and its configuration allows FCoE yet 
> the cnic module is not loaded, it's very likely a null pointer dereference
> will occur, as the bnx2x will erroneously access the FCoE's queue object.
> 
> Prevent said access until cnic properly registers itself.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
