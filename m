From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are writable
Date: Thu, 20 Apr 2017 14:31:48 +0300
Message-ID: <87y3uv48nv.fsf@kamboji.qca.qualcomm.com>
References: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49278 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945121AbdDTLby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 07:31:54 -0400
In-Reply-To: <20170420111651.10213-1-james.hughes@raspberrypi.org> (James
        Hughes's message of "Thu, 20 Apr 2017 12:16:51 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ linux-wireless

James Hughes <james.hughes@raspberrypi.org> writes:

> The driver was adding header information to incoming skb
> without ensuring the head was uncloned and hence writable.
>
> skb_cow_head has been used to ensure they are writable, however,
> this required some changes to error handling to ensure that
> if skb_cow_head failed it was not ignored.
>
> This really needs to be reviewed by someone who is more familiar
> with this code base to ensure any deallocation of skb's is
> still correct.
>
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>

You should also CC linux-wireless, otherwise patchwork won't see it.

-- 
Kalle Valo
