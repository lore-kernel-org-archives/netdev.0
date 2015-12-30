From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] sctp: add the rhashtable apis for sctp
 global transport hashtable
Date: Wed, 30 Dec 2015 12:50:46 -0500 (EST)
Message-ID: <20151230.125046.310343849422003518.davem@davemloft.net>
References: <cover.1451490447.git.lucien.xin@gmail.com>
	<2c413161eb3a2c74453bd8dc11815af7e237515e.1451490447.git.lucien.xin@gmail.com>
	<1451494651.8255.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbbL3Rus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:50:48 -0500
In-Reply-To: <1451494651.8255.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 11:57:31 -0500

> I am against using rhashtable in SCTP (or TCP) at this stage, given the
> number of bugs we have with it.

Come on Eric, we've largely dealt with all of these problems.  I haven't
seen a serious report in a while.
