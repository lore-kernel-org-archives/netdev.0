From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [RFC PATCH v3 2/7] sched: act_mirred: Traffic class option for
 mirror/redirect action
Date: Thu, 14 Sep 2017 00:58:47 -0700
Message-ID: <7bb9f703-af45-a873-d964-f9f49c869375@intel.com>
References: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
 <150529676456.57063.7605464456122745976.stgit@anamdev.jf.intel.com>
 <20170913131843.GB1981@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:12027 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751168AbdINH6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 14 Sep 2017 03:58:52 -0400
In-Reply-To: <20170913131843.GB1981@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2017 6:18 AM, Jiri Pirko wrote:
> Wed, Sep 13, 2017 at 11:59:24AM CEST, amritha.nambiar@intel.com wrote:
>> Adds optional traffic class parameter to the mirror/redirect action.
>> The mirror/redirect action is extended to forward to a traffic
>> class on the device if the traffic class index is provided in
>> addition to the device's ifindex.
> 
> Do I understand it correctly that you just abuse mirred to pas tcclass
> index down to the driver, without actually doing anything with the value
> inside mirred-code ? That is a bit confusing for me.
> 

I think I get your point, I was looking at it more from a hardware
angle, and the 'redirect' action looked quite close to how this actually
works in the hardware. I agree the tclass value in the mirred-code is
not very useful other than offloading it.
