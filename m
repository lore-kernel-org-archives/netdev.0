From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] act_vlan: Introduce TCA_VLAN_ACT_MODIFY vlan
 action
Date: Thu, 22 Sep 2016 01:34:44 -0400 (EDT)
Message-ID: <20160922.013444.419762508426450355.davem@davemloft.net>
References: <1474301470-17965-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: shmulik.ladkani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54630 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbcIVFes (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:34:48 -0400
In-Reply-To: <1474301470-17965-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Date: Mon, 19 Sep 2016 19:11:08 +0300

> TCA_VLAN_ACT_MODIFY allows one to change an existing tag.
> 
> It accepts same attributes as TCA_VLAN_ACT_PUSH (protocol, id,
> priority).
> If packet is vlan tagged, then the tag gets overwritten according to
> user specified attributes.
> 
> For example, this allows user to replace a tag's vid while preserving
> its priority bits (as opposed to "action vlan pop pipe action vlan push").

Series applied.
