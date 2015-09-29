From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: protect tunnel->del_work by ref_count
Date: Mon, 28 Sep 2015 22:39:37 -0700 (PDT)
Message-ID: <20150928.223937.1764472617713444794.davem@davemloft.net>
References: <1443432762-5561-1-git-send-email-lynxis@fe80.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lynxis@fe80.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbbI2Fji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:39:38 -0400
In-Reply-To: <1443432762-5561-1-git-send-email-lynxis@fe80.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Couzens <lynxis@fe80.eu>
Date: Mon, 28 Sep 2015 11:32:42 +0200

> There is a small chance that tunnel_free() is called before tunnel->del_work scheduled
> resulting in a zero pointer dereference.
> 
> Signed-off-by: Alexander Couzens <lynxis@fe80.eu>

Applied and queued up for -stable, thanks.
