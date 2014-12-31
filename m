From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH V3 for 3.19]  rtlwifi: Fix error when accessing unmapped
 memory in skb
Date: Tue, 30 Dec 2014 23:07:35 -0600
Message-ID: <20141231050735.GA20639@zzz>
References: <1419996787-17395-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:33731 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbaLaFHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 00:07:43 -0500
Content-Disposition: inline
In-Reply-To: <1419996787-17395-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2014 at 09:33:07PM -0600, Larry Finger wrote:
> v3 - Unmap skb before trying to allocate a new one so as to not leak mapping.

Looks good to me, although I'm not sure about the handling of DMA mapping errors
(perhaps that's something that drivers typically don't even try to handle?).
Anyway, the skb allocation issue appears to be resolved now.  I am running your
patch with an extra hack to inject some occasional skb allocation failures, and
I haven't noticed any problems except dropped packets.

Eric
