From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: fix potential out of bound access in
 parse_ct
Date: Mon, 24 Jul 2017 16:25:39 -0700 (PDT)
Message-ID: <20170724.162539.1383941457781051443.davem@davemloft.net>
References: <1500803543-7297-1-git-send-email-zlpnobody@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, zlpnobody@gmail.com
To: zlpnobody@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752071AbdGXXZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 19:25:40 -0400
In-Reply-To: <1500803543-7297-1-git-send-email-zlpnobody@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@163.com>
Date: Sun, 23 Jul 2017 17:52:23 +0800

> From: Liping Zhang <zlpnobody@gmail.com>
> 
> Before the 'type' is validated, we shouldn't use it to fetch the
> ovs_ct_attr_lens's minlen and maxlen, else, out of bound access
> may happen.
> 
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Liping Zhang <zlpnobody@gmail.com>

Applied and queued up for -stable.
