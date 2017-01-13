From: Benjamin Poirier <bpoirier@suse.com>
Subject: Re: [PATCH] i40e: Invoke softirqs after napi_reschedule
Date: Thu, 12 Jan 2017 17:51:00 -0800
Message-ID: <20170113015100.duhc4tmqnblqzucq@f1.synalogic.ca>
References: <20170113010414.22708-1-bpoirier@suse.com>
 <1484270130.13165.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56407 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750819AbdAMBvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 20:51:09 -0500
Content-Disposition: inline
In-Reply-To: <1484270130.13165.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017/01/12 17:15, Eric Dumazet wrote:
> On Thu, 2017-01-12 at 17:04 -0800, Benjamin Poirier wrote:
> > The following message is logged from time to time when using i40e:
> > NOHZ: local_softirq_pending 08
> > 
> > i40e may schedule napi from a workqueue. Afterwards, softirqs are not run
> > in a deterministic time frame. The problem is the same as what was
> > described in commit ec13ee80145c ("virtio_net: invoke softirqs after
> > __napi_schedule") and this patch applies the same fix to i40e.
> 
> Yes, I believe mlx4 has a similar problem in mlx4_en_recover_from_oom()

Indeed, I was going to send a patch for mlx4 after this one is accepted.
