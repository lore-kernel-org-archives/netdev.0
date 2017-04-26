From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [1/1] libertas: check return value of alloc_workqueue
Date: Wed, 26 Apr 2017 09:03:41 +0000 (UTC)
Message-ID: <20170426090341.582A46148E@smtp.codeaurora.org>
References: <1492953578-387-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        Tejun Heo <tj@kernel.org>, libertas-dev@lists.infradead.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201603@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:40506 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1435063AbdDZJDm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 05:03:42 -0400
In-Reply-To: <1492953578-387-1-git-send-email-bianpan201603@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pan Bian <bianpan201603@163.com> wrote:
> From: Pan Bian <bianpan2016@163.com>
> 
> Function alloc_workqueue() will return a NULL pointer if there is no
> enough memory, and its return value should be validated before using.
> However, in function if_spi_probe(), its return value is not checked.
> This may result in a NULL dereference bug. This patch fixes the bug.
> 
> Signed-off-by: Pan Bian <bianpan2016@163.com>

Patch applied to wireless-drivers-next.git, thanks.

dc3f89c38a84 libertas: check return value of alloc_workqueue

-- 
https://patchwork.kernel.org/patch/9694827/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
