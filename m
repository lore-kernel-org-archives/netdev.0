From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: Re: [PATCH net] cxgb4/cxgb4vf: Allocate more queues for 100G adapter
Date: Tue, 20 Sep 2016 11:48:36 +0530
Message-ID: <20160920044913.GA14037@hari-Latitude-E5550>
References: <1474272166-30147-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <leedom@chelsio.com>,
        <nirranjan@chelsio.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:54969 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754062AbcITGS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:18:56 -0400
Content-Disposition: inline
In-Reply-To: <1474272166-30147-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 19, 2016 at 01:32:46PM +0530, Hariprasad Shenai wrote:
> We were missing check for 100G while checking port speed, which lead to
> less number of queues getting allocated for 100G and leading to low
> throughput. Adding the missing check for both NIC and vNIC driver.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---

Hi David,

I missed 25G, will send a V2 for the same with changes for 25Gbps adapter too.

Thanks,
Hari 
