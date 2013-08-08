From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 1/4] USB: introduce usb_device_no_sg_constraint()
 helper
Date: Thu, 08 Aug 2013 09:28:32 -0700
Message-ID: <1375979312.4004.111.camel@edumazet-glaptop>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
	 <1375969705-24877-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:57492 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757956Ab3HHQ2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 12:28:35 -0400
In-Reply-To: <1375969705-24877-2-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-08 at 21:48 +0800, Ming Lei wrote:
> Some host controllers(such as xHCI) can support building
> packet from discontinuous buffers, so introduce one flag
> and helper for this kind of host controllers, then the
> feature can help some applications(such as usbnet) by
> supporting arbitrary length of sg buffers.
> 
> Acked-by: Alan Stern <stern@rowland.harvard.edu>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
