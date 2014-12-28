From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 23/23 V2 for 3.19]  rtlwifi: Fix error when accessing unmapped memory in skb
Date: Sun, 28 Dec 2014 07:50:31 +0200
Message-ID: <87a928726w.fsf@kamboji.qca.qualcomm.com>
References: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Stable <stable@vger.kernel.org>,
	Eric Biggers <ebiggers3@gmail.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:47809 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbaL1Fuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 00:50:37 -0500
In-Reply-To: <1419711457-21469-1-git-send-email-Larry.Finger@lwfinger.net>
	(Larry Finger's message of "Sat, 27 Dec 2014 14:17:37 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> writes:

> These drivers use 9100-byte receive buffers, thus allocating an skb requires
> an O(3) memory allocation. Under heavy memory loads and fragmentation, such
> a request can fail. Previous versions of the driver have dropped the packet
> and reused the old buffer; however, the new version introduced a bug in that
> it released the old buffer before trying to allocate a new one. The previous
> method is implemented here.
>
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Stable <stable@vger.kernel.org>  [v3.18]
> Reported-by: Eric Biggers <ebiggers3@gmail.com>
> Cc: Eric Biggers <ebiggers3@gmail.com>
> ---
>
> V2 - Fixes an error in the logic of V1. Realtek is working on a change to
>      the RX buffer allocation, but that is likely to be too invasive for
>      a fix to -rc or stable. In the meantime, this will help.

23/23? Where are patches 1-22? I don't see them in patchwork:

https://patchwork.kernel.org/project/linux-wireless/list/

-- 
Kalle Valo
