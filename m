From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CDC NCM: release interfaces fix in unbind()
Date: Mon, 16 May 2011 15:13:02 -0400 (EDT)
Message-ID: <20110516.151302.89070822321885499.davem@davemloft.net>
References: <1305491307-6548-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	oliver@neukum.org, alexey.orishko@stericsson.com
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1EPTNR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 15:13:17 -0400
In-Reply-To: <1305491307-6548-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Orishko <alexey.orishko@gmail.com>
Date: Sun, 15 May 2011 22:28:27 +0200

> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>

I don't know about this.

The usb_set_intfdata() calls at cdc_ncm_bind() time are unconditional,
and are performed regardless of whether ->data_claimed or
->control_claimed are set.

So conditionalizing the setting of them to NULL here doesn't seem
right at all.

I'm not applying this patch.
