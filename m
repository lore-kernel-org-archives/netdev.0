From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bridge: Fix error path in nbp_vlan_init
Date: Wed, 1 Mar 2017 20:14:35 +0100
Message-ID: <20170301191435.GD2365@nanopsycho>
References: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
        idosch@mellanox.com, eladr@mellanox.com, jiri@mellanox.com,
        roopa@cumulusnetworks.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35862 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753120AbdCATOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 14:14:39 -0500
Received: by mail-wr0-f196.google.com with SMTP id l37so6731093wrc.3
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 11:14:38 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1488379845-38625-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 01, 2017 at 03:50:45PM CET, yotamg@mellanox.com wrote:
>Fix error path order in nbp_vlan_init, so if switchdev_port_attr_set
>call failes, the vlan_hash wouldn't be destroyed before inited.
>
>Fixes: efa5356b0d97 ("bridge: per vlan dst_metadata netlink support")
>CC: Roopa Prabhu <roopa@cumulusnetworks.com>
>Signed-off-by: Yotam Gigi <yotamg@mellanox.com>

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
