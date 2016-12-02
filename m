From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2016-12-01
Date: Fri, 02 Dec 2016 13:58:55 -0500 (EST)
Message-ID: <20161202.135855.9272188465887066.davem@davemloft.net>
References: <877f7jsdmm.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877f7jsdmm.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo@codeaurora.org>
Date: Thu, 01 Dec 2016 20:33:37 +0200

> here's another pull request for net-next. Nothing special to mention
> about, the details are in the signed tag below.
> 
> This time there's a trivial conflict in
> drivers/net/wireless/ath/ath10k/mac.c:
> 
> <<<<<<< HEAD
> 	ieee80211_hw_set(ar->hw, SUPPORTS_TX_FRAG);
> =======
> 	ieee80211_hw_set(ar->hw, REPORTS_LOW_ACK);
>>>>>>>> d5fb3a138048798ce4cc4b4ced47d07d1794c577
> 
> We want to have both flags enabled in ath10k.
> 
> I'm planning to submit at least one more pull request, if Linus gives us
> one more week I might send even two. For example there are patches to
> convert wcn36xx to use the real SMD bus subsystem but they depend on few
> arm-soc patches. I'll send a separate email about that, they are not
> part of this pull request.
> 
> Please let me know if there are any problems.

Pulled, thanks so much for the heads up about the ath10k merge conflict.
