From: David Miller <davem@davemloft.net>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets
Date: Sat, 13 Aug 2011 18:02:22 -0700 (PDT)
Message-ID: <20110813.180222.2091598025825238892.davem@davemloft.net>
References: <CAMvAeqO2bLaPwmdW+c+7hz-ec=-tF6Z0EFBv=FA7+rU_QZ_wDA@mail.gmail.com>
	<CAMvAeqM-oH1UzxEp9PgO6ZP-AKtqosuMg5za25_X8DpPJMDX2w@mail.gmail.com>
	<20110810111947.GC1909@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mguntsche@gmail.com, shemminger@vyatta.com,
	sebastian.belden@googlemail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752822Ab1HNBC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 21:02:28 -0400
In-Reply-To: <20110810111947.GC1909@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Wed, 10 Aug 2011 13:19:48 +0200

> Subject: [patch net-2.6] gianfar: prevent buggy hw rx vlan tagging
> 
> On some buggy chips, "vlan tag present" flag is set which causes packet
> loss. Fix this by checking if rx vlan accel is enabled in features.
> 
> Reported-by: Michael Guntsche <mguntsche@gmail.com>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
