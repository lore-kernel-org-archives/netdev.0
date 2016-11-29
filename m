From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH  v2 01/13] net: ethernet: ti: cpts: switch to
 readl/writel_relaxed()
Date: Tue, 29 Nov 2016 10:38:17 +0100
Message-ID: <20161129093817.GB3110@localhost.localdomain>
References: <20161128230337.6731-1-grygorii.strashko@ti.com>
 <20161128230337.6731-2-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33298 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756779AbcK2JiW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 04:38:22 -0500
Content-Disposition: inline
In-Reply-To: <20161128230337.6731-2-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 05:03:25PM -0600, Grygorii Strashko wrote:
> Switch to readl/writel_relaxed() APIs, because this is recommended
> API and the CPTS IP is reused on Keystone 2 SoCs
> where LE/BE modes are supported.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
