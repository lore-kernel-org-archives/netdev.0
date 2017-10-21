From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: Fix function matching VNI and tunnel ID on
 big-endian
Date: Sat, 21 Oct 2017 02:51:21 +0100 (WEST)
Message-ID: <20171021.025121.1181909163959289258.davem@davemloft.net>
References: <7fb32cd5779c5c0133754194aa6914fa8689853e.1508412016.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org,
        girish.moodalbail@oracle.com, sd@queasysnail.net
To: sbrivio@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753065AbdJUBv0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 21:51:26 -0400
In-Reply-To: <7fb32cd5779c5c0133754194aa6914fa8689853e.1508412016.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>
Date: Thu, 19 Oct 2017 13:31:28 +0200

> On big-endian machines, functions converting between tunnel ID
> and VNI use the three LSBs of tunnel ID storage to map VNI.
> 
> The comparison function eq_tun_id_and_vni(), on the other hand,
> attempted to map the VNI from the three MSBs. Fix it by using
> the same check implemented on LE, which maps VNI from the three
> LSBs of tunnel ID.
> 
> Fixes: 2e0b26e10352 ("geneve: Optimize geneve device lookup.")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>
> ---
> I guess this should be queued up for -stable, back to 4.10

Applied and queued up for -stable, thanks.
