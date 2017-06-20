From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] dccp: call inet_add_protocol after
 register_pernet_subsys in dccp_v6_init
Date: Tue, 20 Jun 2017 15:32:17 -0400 (EDT)
Message-ID: <20170620.153217.1889061771401799918.davem@davemloft.net>
References: <50ab32d7b798e943090fc86b3c96181507907704.1497944684.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751937AbdFTTcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 15:32:19 -0400
In-Reply-To: <50ab32d7b798e943090fc86b3c96181507907704.1497944684.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 20 Jun 2017 15:44:44 +0800

> Patch "call inet_add_protocol after register_pernet_subsys in dccp_v4_init"
> fixed a null pointer dereference issue for dccp_ipv4 module.
> 
> The same fix is needed for dccp_ipv6 module.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
