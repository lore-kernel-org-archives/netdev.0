From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i40e: Invoke softirqs after napi_reschedule
Date: Fri, 13 Jan 2017 20:27:00 -0500 (EST)
Message-ID: <20170113.202700.720848716249365172.davem@davemloft.net>
References: <20170113010414.22708-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60608 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdANB1C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 20:27:02 -0500
In-Reply-To: <20170113010414.22708-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Thu, 12 Jan 2017 17:04:14 -0800

> The following message is logged from time to time when using i40e:
> NOHZ: local_softirq_pending 08
> 
> i40e may schedule napi from a workqueue. Afterwards, softirqs are not run
> in a deterministic time frame. The problem is the same as what was
> described in commit ec13ee80145c ("virtio_net: invoke softirqs after
> __napi_schedule") and this patch applies the same fix to i40e.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

I hope to see this from one of Jeff's pull requests to me in the
near future.
