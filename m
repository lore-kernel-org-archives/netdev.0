From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: fix a memleak that dccp_ipv4 doesn't put
 reqsk properly
Date: Thu, 27 Jul 2017 00:01:28 -0700 (PDT)
Message-ID: <20170727.000128.1018318136609823524.davem@davemloft.net>
References: <795235abacd1bbf9f1144f3094b1f604d513cf65.1501049986.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdG0HB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:01:29 -0400
In-Reply-To: <795235abacd1bbf9f1144f3094b1f604d513cf65.1501049986.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed, 26 Jul 2017 14:19:46 +0800

> The patch "dccp: fix a memleak that dccp_ipv6 doesn't put reqsk
> properly" fixed reqsk refcnt leak for dccp_ipv6. The same issue
> exists on dccp_ipv4.
> 
> This patch is to fix it for dccp_ipv4.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
