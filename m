From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Wed, 30 Nov 2016 19:22:06 +0100
Message-ID: <20161130182206.GA8209@netboy>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-2-grygorii.strashko@ti.com>
 <20161130094441.GB28680@localhost.localdomain>
 <4d69aff4-70a0-e6b8-38b0-8e95cfea7601@ti.com>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35146 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758602AbcK3SWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 13:22:11 -0500
Content-Disposition: inline
In-Reply-To: <4d69aff4-70a0-e6b8-38b0-8e95cfea7601@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2016 at 11:31:56AM -0600, Grygorii Strashko wrote:

> ok. Seems my assumption that ndo_open/ndo_close serialized by
> rtnl_lock is incorrect. Right?

No, you were right in the first place.  The open/close are indeed
serialized by the rtnl lock.

Sorry for the noise,
Richard
