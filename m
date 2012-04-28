From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] pch_gbe: reprogram multicast address register
 on reset
Date: Sat, 28 Apr 2012 18:41:34 +0200
Message-ID: <20120428164133.GB2165@netboy.at.omicron.at>
References: <1335592421-31406-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tshimizu818@gmail.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:40482 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab2D1Qlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 12:41:44 -0400
Received: by wgbdr13 with SMTP id dr13so1736886wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 09:41:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1335592421-31406-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 01:53:41PM +0800, roy.qing.li@gmail.com wrote:
> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> The reset logic after a Rx FIFO overrun will clear the programmed
> multicast addresses. This patch fixes the issue by reprogramming the
> registers after the reset.
> 
> The commit eefc48b tried to fix this problem, but it introduces
> unnecessary codes. In fact, all multicast addresses have been saved
> in netdev->mc, So we can call pch_gbe_set_multi() directly after
> reset_hw and reset_rx.
> 
> This commit kills 50+ line codes

Looks good to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
