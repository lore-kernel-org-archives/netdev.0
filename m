From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mpls: Enforce payload type of traffic sent
 using explicit NULL
Date: Sun, 09 Aug 2015 22:51:54 -0700 (PDT)
Message-ID: <20150809.225154.436246305394293337.davem@davemloft.net>
References: <1438855496-27926-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, tgraf@suug.ch,
	roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbbHJFvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 01:51:55 -0400
In-Reply-To: <1438855496-27926-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Thu, 6 Aug 2015 11:04:56 +0100

> RFC 4182 s2 states that if an IPv4 Explicit NULL label is the only
> label on the stack, then after popping the resulting packet must be
> treated as a IPv4 packet and forwarded based on the IPv4 header. The
> same is true for IPv6 Explicit NULL with an IPv6 packet following.
> 
> Therefore, when installing the IPv4/IPv6 Explicit NULL label routes,
> add an attribute that specifies the expected payload type for use at
> forwarding time for determining the type of the encapsulated packet
> instead of inspecting the first nibble of the packet.
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thanks.
