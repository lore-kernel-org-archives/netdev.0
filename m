From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] Revert "phy: IRQ cannot be shared"
Date: Thu, 25 Aug 2016 16:54:40 -0700 (PDT)
Message-ID: <20160825.165440.1378074913181996224.davem@redhat.com>
References: <e2248086-6087-0fcd-1338-8f6463943c62@cogentembedded.com>
        <1472075273-16257-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, sergei.shtylyov@cogentembedded.com,
        netdev@vger.kernel.org, brad.mouring@ni.com,
        linux-kernel@vger.kernel.org, nathan.sullivan@ni.com
To: xander.huff@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754757AbcHZAEG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 20:04:06 -0400
In-Reply-To: <1472075273-16257-1-git-send-email-xander.huff@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xander Huff <xander.huff@ni.com>
Date: Wed, 24 Aug 2016 16:47:53 -0500

> This reverts:
>   commit 33c133cc7598 ("phy: IRQ cannot be shared")
> 
> On hardware with multiple PHY devices hooked up to the same IRQ line, allow
> them to share it.
> 
> Sergei Shtylyov says:
>   "I'm not sure now what was the reason I concluded that the IRQ sharing
>   was impossible... most probably I thought that the kernel IRQ handling
>   code exited the loop over the IRQ actions once IRQ_HANDLED was returned
>   -- which is obviously not so in reality..."
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> ---
> Note: this reverted code fails "CHECK: Alignment should match open
> parentesis"

That's fine, we can fix up the indentation later.

Applied and queued up for -stable, thanks.
