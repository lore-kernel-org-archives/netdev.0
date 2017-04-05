From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [1/2] wireless: ath9k_htc: fix NULL-deref at probe
Date: Wed, 5 Apr 2017 09:35:23 +0200
Message-ID: <a11d62fc43c54a6d970f593f3cea4120@euamsexm01a.eu.qualcomm.com>
References: <20170313124421.28587-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Daniel Drake <dsd@gentoo.org>,
        Ulrich Kunitz <kune@deine-taler.de>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Johan Hovold <johan@kernel.org>,
        "Sujith Manoharan" <Sujith.Manoharan@atheros.com>
To: Johan Hovold <johan@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:31113 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752862AbdDEHfg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 03:35:36 -0400
In-Reply-To: <20170313124421.28587-1-johan@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johan Hovold <johan@kernel.org> wrote:
> Make sure to check the number of endpoints to avoid dereferencing a
> NULL-pointer or accessing memory beyond the endpoint array should a
> malicious device lack the expected endpoints.
> 
> Fixes: 36bcce430657 ("ath9k_htc: Handle storage devices")
> Cc: Sujith Manoharan <Sujith.Manoharan@atheros.com>
> Signed-off-by: Johan Hovold <johan@kernel.org>

Patch applied to ath-next branch of ath.git, thanks.

ebeb36670eca ath9k_htc: fix NULL-deref at probe

-- 
https://patchwork.kernel.org/patch/9620723/

Documentation about submitting wireless patches and checking status
from patchwork:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
