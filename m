From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 4/4] net: smsc911x: Move interrupt allocation to open/stop
Date: Thu, 1 Sep 2016 22:56:35 +0200
Message-ID: <20160901205635.GD16864@lunn.ch>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
 <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com, will.deacon@arm.com
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33299 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756972AbcIAVXw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 17:23:52 -0400
Content-Disposition: inline
In-Reply-To: <1472760909-19688-5-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 01, 2016 at 03:15:09PM -0500, Jeremy Linton wrote:
> The /proc/irq/xx information is incorrect for smsc911x because
> the request_irq is happening before the register_netdev has the
> proper device name. Moving it to the open also fixes the case
> of when the device is renamed.
> 
> Reported-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Jeremy Linton <jeremy.linton@arm.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
