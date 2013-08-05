From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] vxlan: fix rcu related warning
Date: Sun, 04 Aug 2013 18:47:39 -0700 (PDT)
Message-ID: <20130804.184739.1578984495488739415.davem@davemloft.net>
References: <20130730173516.3d536077@nehalam.linuxnetplumber.net>
	<CALnjE+obgWjqDhuyWUJ=kimMKQbbweenRdxbU1ZCBWBP_qe8Zg@mail.gmail.com>
	<20130804171739.63ee771e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, eric.dumazet@gmail.com,
	tmricht@linux.vnet.ibm.com, mike.rapoport@ravellosystems.com,
	netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab3HEBrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 21:47:40 -0400
In-Reply-To: <20130804171739.63ee771e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 4 Aug 2013 17:17:39 -0700

> Vxlan remote list is protected by RCU and guaranteed to be non-empty.
> Split out the rcu and non-rcu access to the list to fix warning
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Also applied, thanks.
