From: Arthur Kepner <akepner@sgi.com>
Subject: Re: [PATCH] mlx4_core: module param to limit msix vec allocation
Date: Mon, 6 Sep 2010 10:42:45 -0700
Message-ID: <20100906174245.GA12956@sgi.com>
References: <20100903203044.GN2464@sgi.com> <20100903.144658.149830788.davem@davemloft.net> <20100903221303.GS2464@sgi.com> <20100903.193046.184840227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.152.1]:49403 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750822Ab0IFRmr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 13:42:47 -0400
Content-Disposition: inline
In-Reply-To: <20100903.193046.184840227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 03, 2010 at 07:30:46PM -0700, David Miller wrote:
> ...
> Likely there would be a set of policies just like the cpu
> power management layer we have.  And there would be a default,
> and userland could override the default.

Thanks. I had thought this over again, and come up with 
something like what you describe. Testing now, and plan 
to send a work-in-progress patch later today for comments.

> 
> This also means there would have to be notifications sent to
> drivers when the distribution and allocation policy of MSI-X
> interrupts is changed.  This is so that, for example, network
> drivers can reconfigure their network queues for the new set
> of MSI-X vectors available to them after the policy change.

Hadn't considered this. Will have to add it.

-- 
Arthur
