From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: orinoco_usb: Fix buffer on stack
Date: Wed, 26 Apr 2017 09:01:27 +0000 (UTC)
Message-ID: <20170426090127.1658B60B67@smtp.codeaurora.org>
References: <20170422170306.11668-1-maksim.salau@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Florian Westphal <fw@strlen.de>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Maksim Salau <maksim.salau@gmail.com>
To: Maksim Salau <maksim.salau@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38914 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1957359AbdDZJB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:01:28 -0400
In-Reply-To: <20170422170306.11668-1-maksim.salau@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maksim Salau <maksim.salau@gmail.com> wrote:
> Allocate buffer on HEAP instead of STACK for a local variable
> that is to be sent using usb_control_msg().
> 
> Signed-off-by: Maksim Salau <maksim.salau@gmail.com>

Patch applied to wireless-drivers-next.git, thanks.

2f6ae79cb04b orinoco_usb: Fix buffer on stack

-- 
https://patchwork.kernel.org/patch/9694451/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
