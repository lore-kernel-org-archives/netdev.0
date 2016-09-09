From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: scan: Simplify code
Date: Fri,  9 Sep 2016 09:21:45 +0000 (UTC)
Message-ID: <20160909092145.2A21861EAC@smtp.codeaurora.org>
References: <1472644259-15605-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akarwar@marvell.com, nishants@marvell.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: Christophe Jaillet <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:55815 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbcIIJVp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 05:21:45 -0400
In-Reply-To: <1472644259-15605-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christophe Jaillet <christophe.jaillet@wanadoo.fr> wrote:
> This patch:
>    - improves code layout
>    - removes a useless memset(0) for some memory allocated with kzalloc
>    - removes a useless if. We know that 'if (chan_band_tlv)' will succeed
>      because it has been tested a few lines above
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Thanks, 1 patch applied to wireless-drivers-next.git:

b71165761694 mwifiex: scan: Simplify code

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9307009/
