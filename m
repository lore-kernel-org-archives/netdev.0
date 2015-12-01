From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] Revert "ipv6: ndisc: inherit metadata dst when
 creating ndisc requests"
Date: Tue, 01 Dec 2015 15:08:20 -0500 (EST)
Message-ID: <20151201.150820.1874041911924649780.davem@davemloft.net>
References: <1448644625-29345-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jbenc@redhat.com, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575AbbLAUIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:08:22 -0500
In-Reply-To: <1448644625-29345-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 27 Nov 2015 18:17:05 +0100

> This reverts commit ab450605b35caa768ca33e86db9403229bf42be4.
> 
> In IPv6, we cannot inherit the dst of the original dst. ndisc packets
> are IPv6 packets and may take another route than the original packet.
> 
> This patch breaks the following scenario: a packet comes from eth0 and
> is forwarded through vxlan1. The encapsulated packet triggers an NS
> which cannot be sent because of the wrong route.
> 
> CC: Jiri Benc <jbenc@redhat.com>
> CC: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
> 
> I know that this is not the right fix, it's why I've put RFC ;-)
> Should the right fix only do a copy of dst metadata in the new dst?
> Feedback is welcomed.

Ok I'll apply this revert while you guys try to come up with something
better.

Thanks.
