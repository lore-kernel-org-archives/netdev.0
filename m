From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 0/4] Configuring traffic classes via new hardware offload
 mechanism in tc/mqprio
Date: Fri, 21 Jul 2017 11:42:44 +0200
Message-ID: <20170721094244.nkkmvb7fvk6akbvq@localhost.localdomain>
References: <149524122523.11022.4541073724650541658.stgit@anamdev.jf.intel.com>
 <1495481472.4878.4.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org,
        Or Gerlitz <gerlitz.or@gmail.com>, alexander.h.duyck@intel.com,
        kiran.patil@intel.com, sridhar.samudrala@intel.com,
        mitch.a.williams@intel.com, neerav.parikh@intel.com,
        netdev@vger.kernel.org, John Fastabend <john.fastabend@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38463 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753617AbdGUJmv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 05:42:51 -0400
Received: by mail-wr0-f194.google.com with SMTP id p12so3941876wrc.5
        for <netdev@vger.kernel.org>; Fri, 21 Jul 2017 02:42:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1495481472.4878.4.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 22, 2017 at 12:31:12PM -0700, Jeff Kirsher wrote:
> On Fri, 2017-05-19 at 17:58 -0700, Amritha Nambiar wrote:
> > The following series introduces a new harware offload mode in tc/mqprio
> > where the TCs, the queue configurations and bandwidth rate limits are
> > offloaded to the hardware.

...

> This was meant to be sent out as an RFC, but apparently that did not get
> conveyed when these were sent out Friday.

I am looking at tc/mqprio and dcb with the purpose of implementing 

  - Forwarding and Queuing Enhancements for Time-Sensitive Streams (FQTSS)
    802.1Q-2014 Clause 34

  - Scheduled Traffic (time based scheduling)
    P802.1Qbv

using the HW capabilities of the i210.  This series looks like a
promising avenue for these features.

My question is, did series go anywhere?

I didn't see any follow ups on netdev, but maybe I missed something.

Thanks,
Richard
