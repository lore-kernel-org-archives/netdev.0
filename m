From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v10] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 12:50:21 +0200
Message-ID: <20170926125021.01ef2ae1@griffin>
References: <1506401236-5716-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37450 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934183AbdIZKuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 06:50:25 -0400
In-Reply-To: <1506401236-5716-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 12:47:16 +0800, Yi Yang wrote:
> v9->v10
>  - Change struct ovs_key_nsh to
>        struct ovs_nsh_key_base base;
>        __be32 context[NSH_MD1_CONTEXT_SIZE];
>  - Fix new comments for v9

NAK, we haven't finished the discussion for v9 yet. It's not
appropriate to send a new version until there's a conclusion (or at
least until the discussion dies).

 Jiri
