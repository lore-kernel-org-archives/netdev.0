From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/3] net: mpls: fragmentation and gso fixes
 for locally originated traffic
Date: Tue, 30 Aug 2016 22:27:41 -0700 (PDT)
Message-ID: <20160830.222741.1708672778295152441.davem@davemloft.net>
References: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, buytenh@wantstofly.org,
        simon.horman@netronome.com, ebiederm@xmission.com,
        rshearma@brocade.com, tom@herbertland.com, tgraf@suug.ch,
        olivier.dugeon@orange.com, alexander.duyck@gmail.com,
        roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37860 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcHaF1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 01:27:44 -0400
In-Reply-To: <1472094645-11452-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 24 Aug 2016 20:10:42 -0700

> This series fixes mtu and fragmentation for tunnels using lwtunnel
> output redirect, and fixes GSO for MPLS for locally originated traffic
> reported by Lennert Buytenhek.
> 
> A follow on series will address fragmentation and GSO for forwarded
> MPLS traffic. Hardware offload of GSO with MPLS also needs to be
> addressed.
> 
> Simon: Can you verify this works with OVS for single and multiple
>        labels?

Series applied, thanks.
