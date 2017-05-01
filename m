From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: Remove NETDEV_CHANGEINFODATA
Date: Sun, 30 Apr 2017 22:46:07 -0400 (EDT)
Message-ID: <20170430.224607.204194421266945226.davem@davemloft.net>
References: <1493402785-18844-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165129AbdEACqJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:46:09 -0400
In-Reply-To: <1493402785-18844-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 28 Apr 2017 11:06:25 -0700

> NETDEV_CHANGEINFODATA was added by d4261e5650004 ("bonding: create
> netlink event when bonding option is changed"). RTM_NEWLINK
> messages are already created on changelink events, so this event
> is just a duplicate. Remove it.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

I think you need to respin this, I get rejects when I try to
apply this to net-next.
