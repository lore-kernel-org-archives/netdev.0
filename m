From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: warn about missing first netlink
 attribute
Date: Thu, 08 Jun 2017 15:57:33 -0400 (EDT)
Message-ID: <20170608.155733.699170449509726938.davem@davemloft.net>
References: <1496911065-6912-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdFHT5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 15:57:36 -0400
In-Reply-To: <1496911065-6912-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  8 Jun 2017 10:37:45 +0200

> The first netlink attribute (value 0) must always be defined
> as none/unspec.
> 
> Because we cannot change an existing UAPI, I add a comment to point the
> mistake and avoid to propagate it in a new ovs API in the future.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Ok, I agree, we don't want people cut-and-pasting this kind of thing
and hopefully this comment prevents that.

Applied, thanks.
