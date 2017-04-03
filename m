From: Florian Larysch <fl@n621.de>
Subject: Re: [PATCH] net: ipv4: fix multipath RTM_GETROUTE behavior when iif
 is given
Date: Mon, 3 Apr 2017 20:06:01 +0200
Message-ID: <20170403180601.GH23387@nyx.n621.de>
References: <20170403144609.18716-1-fl@n621.de>
 <26f917bb-d44a-e397-1145-58d5e4e823f3@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nyx.n621.de ([176.9.182.227]:48254 "EHLO nyx.n621.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753188AbdDCSLG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Apr 2017 14:11:06 -0400
Content-Disposition: inline
In-Reply-To: <26f917bb-d44a-e397-1145-58d5e4e823f3@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 03, 2017 at 01:33:39PM -0400, David Ahern wrote:
> that function no longer exists since Nik's recent work
> (bf4e0a3db97eb882368fd82980b3b1fa0b5b9778)

Didn't notice that as I was looking at Linus' tree. Thanks.

> So does the problem you noted still exist?

Yes. And in fact, that change invalidates the fix I proposed. I'll
submit something new for net-next.

Florian
