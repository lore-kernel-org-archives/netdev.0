From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] brcmfmac: Ensure pointer correctly set if skb data location
 changes
Date: Wed, 26 Apr 2017 09:04:49 +0000 (UTC)
Message-ID: <20170426090449.2C8346149F@smtp.codeaurora.org>
References: <20170424114050.24948-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        James Hughes <james.hughes@raspberrypi.org>
To: James Hughes <james.hughes@raspberrypi.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41728 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966124AbdDZJEt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:04:49 -0400
In-Reply-To: <20170424114050.24948-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Hughes <james.hughes@raspberrypi.org> wrote:
> The incoming skb header may be resized if header space is
> insufficient, which might change the data adddress in the skb.
> Ensure that a cached pointer to that data is correctly set by
> moving assignment to after any possible changes.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
> 
> Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>

Patch applied to wireless-drivers-next.git, thanks.

455a1eb4654c brcmfmac: Ensure pointer correctly set if skb data location changes

-- 
https://patchwork.kernel.org/patch/9696045/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
