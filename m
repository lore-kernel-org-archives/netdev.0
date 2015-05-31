From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 00/11] net: Increase inputs to flow_keys
 hashing
Date: Sat, 30 May 2015 23:40:55 -0700 (PDT)
Message-ID: <20150530.234055.272009415711917768.davem@davemloft.net>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbbEaGk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:40:56 -0400
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 28 May 2015 11:18:57 -0700

> This patch set adds new fields to the flow_keys structure and hashes
> over these fields to get a better flow hash. In particular, these
> patches now include hashing over the full IPv6 addresses in order
> to defend against address spoofing that always results in the
> same hash. The new input also includes the Ethertype, L4 protocol,
> VLAN, flow label, GRE keyid, and MPLS entropy label.

Looks like one more respin needed of this based upon Jiri's feedback.
