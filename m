From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] gre: allow to switch netns during
 encap/decap
Date: Wed, 23 Apr 2014 14:54:16 -0400 (EDT)
Message-ID: <20140423.145416.1660273363864199935.davem@davemloft.net>
References: <1398154524-5928-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, mzero@google.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090AbaDWSyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 14:54:18 -0400
In-Reply-To: <1398154524-5928-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 22 Apr 2014 10:15:22 +0200

> The goal of this serie is to add x-netns support for the module ip_gre and
> ip6_gre, ie the encapsulation addresses and the network device are not owned by
> the same namespace.
> 
> Example to configure an ipv4 gre tunnel:
> 
> modprobe ip_gre
> ip netns add netns1
> ip netns exec netns1 ip link set lo up
> ip link add gre1 type gre remote 10.16.0.121 local 10.16.0.249 ikey 10 okey 10 csum
> ip link set gre1 netns netns1
> ip netns exec netns1 ip link set gre1 up
> ip netns exec netns1 ip addr add dev gre1 192.168.0.249 remote 192.168.0.121

Looks good, series applied, thanks Nicolas.
