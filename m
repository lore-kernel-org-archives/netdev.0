From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] sky2: Remove failure cases for sky2_rx_start
Date: Wed, 27 Jan 2010 09:10:24 -0800
Message-ID: <20100127091024.2ac97d81@nehalam>
References: <4B605652.6020400@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42530 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab0A0RKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2010 12:10:35 -0500
In-Reply-To: <4B605652.6020400@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2010 00:05:54 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> sky2_rx_start() can no longer fail, so remove redundant code pathes.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

This can't work right if MTU is increased. The buffers need to be reallocated
in change_mtu(); and yes it could fail when getting the new buffers.


-- 
