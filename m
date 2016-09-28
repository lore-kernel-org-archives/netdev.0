From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 3/6] net: phy: Threaded interrupts allow some
 simplification
Date: Wed, 28 Sep 2016 14:46:27 +0300
Message-ID: <7997d337-cd0f-ab39-1f53-df996063932b@cogentembedded.com>
References: <1475051544-18561-1-git-send-email-andrew@lunn.ch>
 <1475051544-18561-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35979 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753550AbcI1Lqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 07:46:31 -0400
Received: by mail-lf0-f45.google.com with SMTP id g62so48336815lfe.3
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 04:46:30 -0700 (PDT)
In-Reply-To: <1475051544-18561-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/28/2016 11:32 AM, Andrew Lunn wrote:

> The PHY interrupts are now handled in a threaded interrupt handler,
> which can sleep. The work queue is no longer needed, phy_change() can
> be called directly. Additionally, none of the callers of
> phy_mac_interrupt() did so in interrupt context, so fully remove the

    I did intend to call it from interrupt context (from the ravb driver).

> work queue, and document that phy_mac_interrupt() should not be called
> in interrupt context.

    It was intentionally made callable from the interrupt context, I'd prefer 
if you wouldn't change that.

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
[...]

MBR, Sergei
