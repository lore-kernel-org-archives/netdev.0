From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] ipv4: Namespecify TCP PMTU mechanism
Date: Mon, 09 Feb 2015 14:09:11 -0800 (PST)
Message-ID: <20150209.140911.1096080668059319311.davem@redhat.com>
References: <1423471498-22442-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: fan.du@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756140AbbBIWJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 17:09:23 -0500
In-Reply-To: <1423471498-22442-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>
Date: Mon,  9 Feb 2015 16:44:58 +0800

> Packetization Layer Path MTU Discovery works separately beside
> Path MTU Discovery at IP level, different net namespace has
> various requirements on which one to chose, e.g., a virutalized
> container instance would require TCP PMTU to probe an usable
> effective mtu for underlying tunnel, while the host would
> employ classical ICMP based pmtu to function.
> 
> Hence making TCP PMTU mechanism per net namespace to decouple
> two functionality. Furthermore the probe base MSS should also
> be configured separately for each namespace.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>

This does not apply cleanly to net-next, please respin.
