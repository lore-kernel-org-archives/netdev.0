From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Sun, 13 Aug 2017 20:00:58 -0700 (PDT)
Message-ID: <20170813.200058.1843060234396695160.davem@davemloft.net>
References: <1502490059-24229-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, netdev@vger.kernel.org,
        mschiffer@universe-factory.net, jbenc@redhat.com,
        roopa@cumulusnetworks.com
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHNDA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 23:00:59 -0400
In-Reply-To: <1502490059-24229-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Fri, 11 Aug 2017 15:20:59 -0700

> The kernel log is not where users expect error messages for netlink
> requests; as we have extended acks now, we can replace pr_debug() with
> NL_SET_ERR_MSG_ATTR().
> 
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

Applied, thanks.
