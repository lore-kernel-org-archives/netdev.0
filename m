From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] vxlan: correctly validate VXLAN ID against
 VXLAN_N_VID
Date: Fri, 24 Feb 2017 11:20:34 -0500 (EST)
Message-ID: <20170224.112034.268653979298256762.davem@davemloft.net>
References: <4650647d72b8f219cb725b40de9b4627f3306919.1487866739.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, netdev@vger.kernel.org
To: mschiffer@universe-factory.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdBXQ1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:27:32 -0500
In-Reply-To: <4650647d72b8f219cb725b40de9b4627f3306919.1487866739.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>
Date: Thu, 23 Feb 2017 17:19:41 +0100

> The incorrect check caused an off-by-one error: the maximum VID 0xffffff
> was unusable.
> 
> Fixes: d342894c5d2f ("vxlan: virtual extensible lan")
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>

Applied and queued up for -stable, thanks.
