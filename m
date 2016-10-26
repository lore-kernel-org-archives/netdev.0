From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next] net: dev: Fix non-RCU based lower dev walker
Date: Wed, 26 Oct 2016 23:46:43 +0300
Message-ID: <20161026204643.cvtiasnsoj6ku7ex@splinter>
References: <1477513293-10117-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:52058 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933435AbcJZUrK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 16:47:10 -0400
Content-Disposition: inline
In-Reply-To: <1477513293-10117-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 01:21:33PM -0700, David Ahern wrote:
> netdev_walk_all_lower_dev is not properly walking the lower device
> list.  Commit 1a3f060c1a47 made netdev_walk_all_lower_dev similar
> to netdev_walk_all_upper_dev_rcu and netdev_walk_all_lower_dev_rcu
> but failed to update its netdev_next_lower_dev iterator. This patch
> fixes that.
> 
> Fixes: 1a3f060c1a47 ("net: Introduce new api for walking upper and
>                      lower devices")
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks David.
