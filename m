From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 05/12] ftgmac100: Pad small frames properly
Date: Sat, 08 Apr 2017 09:15:20 +1000
Message-ID: <1491606920.4166.163.camel@kernel.crashing.org>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
         <20170407033105.29558-6-benh@kernel.crashing.org>
         <09187038-06b1-82d2-1fda-1fea1c119a0a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57396 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753853AbdDGXP0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 19:15:26 -0400
In-Reply-To: <09187038-06b1-82d2-1fda-1fea1c119a0a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-07 at 06:05 -0700, Florian Fainelli wrote:
> You may want to use skb_put_padto() which also takes care of bumping
> skb->len accordingly, in case that makes a difference for the
> ftgmac100 hardware.

Subsequent patch adds fragments, so it needs to bump headlen. I'll have
a look this week-end, thanks.

Cheers,
Ben.
