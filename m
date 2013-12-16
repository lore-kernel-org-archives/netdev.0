From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: use interface mtu for determining if
 packet-too-big should be send
Date: Mon, 16 Dec 2013 05:49:42 -0800
Message-ID: <1387201782.19078.230.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131216080914.GA28677@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:47066 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752Ab3LPNtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:49:43 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so5372484pdj.3
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 05:49:43 -0800 (PST)
In-Reply-To: <20131216080914.GA28677@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 09:09 +0100, Hannes Frederic Sowa wrote:
> IPv6 forwarding path should also not depend on the path mtu values to
> judge if a packet should get dropped and an ICMP PTB should be returned.
> 
> For the accompanying change in IPv4, have a look at "ipv4: introduce
> ip_dst_mtu_secure and protect forwarding path against pmtu spoofing".
> 

No commit sha1 (truncated to 12 digits) ?

> I needed to move in6_dev_dev around to keep ip6_dst_mtu_secure as a static
> inline function in the header and to keep header dependencies happy.
> 
> For the IPv4 change, see patch "ipv4: introduce ip_dst_mtu_secure and
> protect forwarding path against pmtu spoofing".

Redundant sentence ?

And no documentation for the new setting.

git grep -n forward_use_pmtu Documentation

Thanks
