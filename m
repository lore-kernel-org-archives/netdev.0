From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: Remove unused function usb_ocp_read()
Date: Thu, 18 May 2017 14:46:39 -0400 (EDT)
Message-ID: <20170518.144639.741785562694390701.davem@davemloft.net>
References: <20170518174533.79413-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mka@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbdERSqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 14:46:43 -0400
In-Reply-To: <20170518174533.79413-1-mka@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <mka@chromium.org>
Date: Thu, 18 May 2017 10:45:33 -0700

> The function is not used, removing it fixes the following warning when
> building with clang:
> 
> drivers/net/usb/r8152.c:825:5: error: unused function 'usb_ocp_read'
>     [-Werror,-Wunused-function]
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Applied to net-next.
