From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Fri, 11 Aug 2017 11:10:55 +0200
Message-ID: <20170811111055.482bd42b@griffin>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
        <20170811102418.6b1be4f7@griffin>
        <20170811084722.GA19968@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: "Yang, Yi" <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54402 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751521AbdHKJK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 05:10:57 -0400
In-Reply-To: <20170811084722.GA19968@cran64.bj.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 16:47:23 +0800, Yang, Yi wrote:
> is "__be32 context[4]" ok?

Yes, that looks better.

> So define three new netlink attributes
> 
> OVS_ACTION_ATTR_NSH_BASE_HEADER
> OVS_ACTION_ATTR_NSH_MD1_DATA
> OVS_ACTION_ATTR_NSH_MD2_DATA
> 
> OVS_ACTION_ATTR_PUSH_NSH is nested netlink attribute, it will nest
> OVS_ACTION_ATTR_NSH_BASE_HEADER and OVS_ACTION_ATTR_NSH_MD1_DATA for MD
> type 1, it will nest OVS_ACTION_ATTR_NSH_BASE_HEADER and
> OVS_ACTION_ATTR_NSH_MD2_DATA for MD type 2. I'll compeletely remove struct
> ovs_action_push_nsh, is it ok?

Yes, that's the way to do it.

What should be done with struct ovs_key_nsh? Even with "c" renamed to
"context", it's still MD type 1 only structure. What is the plan for
MD type 2 support wrt. this structure?

Thanks,

 Jiri
