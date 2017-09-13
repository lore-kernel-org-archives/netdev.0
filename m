From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH v3 2/7] sched: act_mirred: Traffic class option for
 mirror/redirect action
Date: Wed, 13 Sep 2017 15:18:43 +0200
Message-ID: <20170913131843.GB1981@nanopsycho>
References: <150529632024.57063.15338545678487601430.stgit@anamdev.jf.intel.com>
 <150529676456.57063.7605464456122745976.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        alexander.h.duyck@intel.com, netdev@vger.kernel.org,
        mlxsw@mellanox.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:45419 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdIMNSq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 09:18:46 -0400
Received: by mail-wm0-f48.google.com with SMTP id g206so6642209wme.0
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 06:18:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <150529676456.57063.7605464456122745976.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Sep 13, 2017 at 11:59:24AM CEST, amritha.nambiar@intel.com wrote:
>Adds optional traffic class parameter to the mirror/redirect action.
>The mirror/redirect action is extended to forward to a traffic
>class on the device if the traffic class index is provided in
>addition to the device's ifindex.

Do I understand it correctly that you just abuse mirred to pas tcclass
index down to the driver, without actually doing anything with the value
inside mirred-code ? That is a bit confusing for me.
