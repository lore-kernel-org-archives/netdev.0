From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ip_tunnel: Allow policy-based routing
 through tunnels
Date: Fri, 21 Apr 2017 13:21:54 -0400 (EDT)
Message-ID: <20170421.132154.675013808656729933.davem@davemloft.net>
References: <20170419163054.31173-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37218 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424623AbdDUTRf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:17:35 -0400
In-Reply-To: <20170419163054.31173-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Wed, 19 Apr 2017 12:30:52 -0400

> iproute2 changes to follow.  Example usage:
>   ip link add gre-test type gre local 10.0.0.1 remote 10.0.0.2 fwmark 0x4
>   ip -detail link show gre-test
>   ...
>   ip link set gre-test type gre fwmark 0

Looks good, series applied, thanks.
