From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 10/13] ftgmac100: Add a reset task and use it for link
 changes
Date: Wed, 5 Apr 2017 17:00:46 +0200
Message-ID: <20170405150046.GH13449@lunn.ch>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
 <20170405022853.8238-11-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46686 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932092AbdDEPAr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 11:00:47 -0400
Content-Disposition: inline
In-Reply-To: <20170405022853.8238-11-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 05, 2017 at 12:28:50PM +1000, Benjamin Herrenschmidt wrote:
> Link speed changes require a full HW reset. This isn't done
> properly at the moment. It will involve delays and thus isn't
> suitable to do from the link poll callback.
> 
> So let's create a reset_task that we can queue up when the
> link changes. It will be useful for various cases of error
> handling as well.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
