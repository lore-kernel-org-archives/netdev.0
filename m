From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: Allow IPv4-mapped address as next-hop
Date: Wed, 30 Nov 2016 10:58:57 -0500 (EST)
Message-ID: <20161130.105857.656098579060491142.davem@davemloft.net>
References: <20161128181000.CED72D3427AA@us153.sjc.aristanetworks.com>
        <76e59d76-7905-bb14-43d6-d4aaba51f0f9@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, gilligan@arista.com
To: nordmark@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753898AbcK3P67 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:58:59 -0500
In-Reply-To: <76e59d76-7905-bb14-43d6-d4aaba51f0f9@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Nordmark <nordmark@arista.com>
Date: Mon, 28 Nov 2016 15:27:05 -0800

> @@ -1995,8 +1995,11 @@ static struct rt6_info *ip6_route_info_c
>  			   It is very good, but in some (rare!) circumstances
>  			   (SIT, PtP, NBMA NOARP links) it is handy to allow
>  			   some exceptions. --ANK
> + We allow IPv4-mapped nexthops to support RFC4798-type
> +			   addressing
>  			 */

This is definitely not indented and formatted correctly, please fix.
