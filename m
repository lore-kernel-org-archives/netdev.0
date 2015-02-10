From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next] ipv4: Namespecify TCP PMTU mechanism
Date: Mon, 09 Feb 2015 18:45:31 -0800 (PST)
Message-ID: <20150209.184531.1242787737821380537.davem@davemloft.net>
References: <1423471498-22442-1-git-send-email-fan.du@intel.com>
	<1423533196-22166-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbbBJCpc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 21:45:32 -0500
In-Reply-To: <1423533196-22166-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Tue, 10 Feb 2015 09:53:16 +0800

> Packetization Layer Path MTU Discovery works separately beside
> Path MTU Discovery at IP level, different net namespace has
> various requirements on which one to chose, e.g., a virutalized
> container instance would require TCP PMTU to probe an usable
> effective mtu for underlying tunnel, while the host would
> employ classical ICMP based PMTU to function.
> 
> Hence making TCP PMTU mechanism per net namespace to decouple
> two functionality. Furthermore the probe base MSS should also
> be configured separately for each namespace.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>

Applied.
