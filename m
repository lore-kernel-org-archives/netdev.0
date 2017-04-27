From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: vrf: Do not allow looback to be moved to
 a VRF
Date: Thu, 27 Apr 2017 16:50:04 -0400 (EDT)
Message-ID: <20170427.165004.1347871791807750987.davem@davemloft.net>
References: <1493218702-10906-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45708 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967179AbdD0UuI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 16:50:08 -0400
In-Reply-To: <1493218702-10906-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 26 Apr 2017 07:58:22 -0700

> Moving the loopback into a VRF breaks networking for the default VRF.
> Since the VRF device is the loopback for VRF domains, there is no
> reason to move the loopback. Given the repercussions, block attempts
> to set lo into a VRF.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
