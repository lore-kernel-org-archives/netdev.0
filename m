From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] via-velocity: remove null pointer check on array
 tdinfo->skb_dma
Date: Thu, 8 Sep 2016 22:38:16 +0200
Message-ID: <20160908203816.GA8128@electric-eye.fr.zoreil.com>
References: <20160908090424.16545-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55615 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbcIHUq1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 16:46:27 -0400
Content-Disposition: inline
In-Reply-To: <20160908090424.16545-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Colin King <colin.king@canonical.com> :
> From: Colin Ian King <colin.king@canonical.com>
> 
> tdinfo->skb_dma is a 7 element array of dma_addr_t hence cannot be
> null, so the pull pointer check on tdinfo->skb_dma  is redundant.
> Remove it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

-- 
Ueimor
