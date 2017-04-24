From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH 1/1] mt7601u: check return value of alloc_skb
Date: Sun, 23 Apr 2017 20:49:43 -0700
Message-ID: <20170423204943.3ce98a63@laptop>
References: <1492930823-17249-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:24296 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164533AbdDXDtw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 23:49:52 -0400
In-Reply-To: <1492930823-17249-1-git-send-email-bianpan2016@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Apr 2017 15:00:23 +0800, Pan Bian wrote:
> Function alloc_skb() will return a NULL pointer if there is no enough
> memory. However, in function mt7601u_mcu_msg_alloc(), its return value
> is not validated before it is used. This patch fixes it.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Acked-by: Jakub Kicinski <kubakici@wp.pl>

Thanks!
