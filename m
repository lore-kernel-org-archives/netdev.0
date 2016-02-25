From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] vxlan: consolidate rx handling
Date: Thu, 25 Feb 2016 15:19:41 -0500 (EST)
Message-ID: <20160225.151941.1711130624257189771.davem@davemloft.net>
References: <cover.1456246786.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744AbcBYUTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:19:43 -0500
In-Reply-To: <cover.1456246786.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue, 23 Feb 2016 18:02:54 +0100

> Currently, vxlan_rcv is just called at the end of vxlan_udp_encap_recv,
> continuing the rx processing where vxlan_udp_encap_recv left it. There's no
> clear border between those two functions. This patchset moves
> vxlan_udp_encap_recv and vxlan_rcv into a single function.
> 
> This also allows to do some simplification in error path.
> 
> The VXLAN-GPE implementation that will follow up this set can be seen at:
> https://github.com/jbenc/linux-vxlan/commits/master

Series applied, thank you.
