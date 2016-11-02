From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v5 6/7] net: ethernet: bgmac: add NS2 support
Date: Wed, 2 Nov 2016 10:17:26 -0700
Message-ID: <82979ee0-1473-90fd-a9d1-23a86ce09aa8@gmail.com>
References: <1478106488-11779-1-git-send-email-jon.mason@broadcom.com>
 <1478106488-11779-7-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35613 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932946AbcKBRRa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 13:17:30 -0400
In-Reply-To: <1478106488-11779-7-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2016 10:08 AM, Jon Mason wrote:
> Add support for the variant of amac hardware present in the Broadcom
> Northstar2 based SoCs.  Northstar2 requires an additional register to be
> configured with the port speed/duplexity (NICPM).  This can be added to
> the link callback to hide it from the instances that do not use this.
> Also, clearing of the pending interrupts on init is required due to
> observed issues on some platforms.
> 
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
