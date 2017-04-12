From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 2/5] genetlink: pass extended ACK report down
Date: Wed, 12 Apr 2017 16:01:34 +0200
Message-ID: <20170412140134.GI1952@nanopsycho>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-3-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Johannes Berg <johannes.berg@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36718 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752484AbdDLOBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:01:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id q125so6597292wmd.3
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 07:01:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170412123408.22012-3-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 12, 2017 at 02:34:05PM CEST, johannes@sipsolutions.net wrote:
>From: Johannes Berg <johannes.berg@intel.com>
>
>Pass the extended ACK reporting struct down from generic
>netlink to the families, using the existing struct
>genl_info for simplicity.
>
>Also add support to set the extended ACK information from
>generic netlink users.
>
>Signed-off-by: Johannes Berg <johannes.berg@intel.com>
>---

Aside from the tinyfication of desc lines, this looks good to me

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
