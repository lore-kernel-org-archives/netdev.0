From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net] nfp: do not update MTU from BH in flower app
Date: Fri, 11 Aug 2017 10:10:24 +0200
Message-ID: <20170811081021.GA12975@verge.net.au>
References: <1502438823-12830-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:44566 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdHKIKo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 04:10:44 -0400
Content-Disposition: inline
In-Reply-To: <1502438823-12830-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 10:07:03AM +0200, Simon Horman wrote:
> The Flower app may receive a request to update the MTU of a representor
> netdev upon receipt of a control message from the firmware. This requires
> the RTNL lock which needs to be taken outside of the packet processing
> path.
> 
> As a handling of this correctly seems a little to invasive for a fix simply
> skip setting the MTU for now.

Sorry, please ignore this.

It is not against net as it claims. I will post a version against that tree.
