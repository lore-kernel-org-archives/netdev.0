From: Hangbin Liu <haliu@redhat.com>
Subject: Re: [PATCHv3 iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Thu, 28 Sep 2017 15:13:06 +0800
Message-ID: <20170928071306.GB1498@leo.usersys.redhat.com>
References: <1505871820-31580-1-git-send-email-liuhangbin@gmail.com>
 <1505871820-31580-2-git-send-email-liuhangbin@gmail.com>
 <20170920095605.1ea527fc@xeon-e3>
 <20170921072002.GM5465@leo.usersys.redhat.com>
 <20170921073420.dcoipli2sxy3bmnx@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46042 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750794AbdI1HNM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 03:13:12 -0400
Content-Disposition: inline
In-Reply-To: <20170921073420.dcoipli2sxy3bmnx@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Thu, Sep 21, 2017 at 09:34:20AM +0200, Michal Kubecek wrote:
> I will have to check but IIRC it might be possible to use zero length
> for the peek to only check the length which could help you to avoid both
> the reallocation and copying the same data from kernel to userspace
> twice.

Yes, msg with zero buf length also works. I will post a new patch after fix.

Thanks
Hangbin
