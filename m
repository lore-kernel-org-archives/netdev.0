From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 2/2] net: bridge: allow to add externally
 learned entries from user-space
Date: Thu, 23 Mar 2017 21:47:57 +0200
Message-ID: <20170323194757.GB25688@splinter.mtl.com>
References: <1490264833-28867-1-git-send-email-nikolay@cumulusnetworks.com>
 <1490264833-28867-3-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, jiri@resnulli.us,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        roopa@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:49493 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933031AbdCWTsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 15:48:11 -0400
Content-Disposition: inline
In-Reply-To: <1490264833-28867-3-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 23, 2017 at 12:27:13PM +0200, Nikolay Aleksandrov wrote:
> The NTF_EXT_LEARNED flag was added for switchdev and externally learned
> entries, but it can also be used for entries learned via a software
> in user-space which requires dynamic entries that do not expire.
> One such case that we have is with quagga and evpn which need dynamic
> entries but also require to age them themselves.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
