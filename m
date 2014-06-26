From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: mark packets sent to any local mac address as
 PACKET_HOST
Date: Thu, 26 Jun 2014 13:35:50 -0700 (PDT)
Message-ID: <20140626.133550.975175623908419742.davem@davemloft.net>
References: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
	<20140625161335.11598f09@haswell>
	<1403781352.52578.103.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbaFZUfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 16:35:51 -0400
In-Reply-To: <1403781352.52578.103.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Bizon <mbizon@freebox.fr>
Date: Thu, 26 Jun 2014 13:15:52 +0200

> for some reasons, hostapd kept adding and removing the interface from
> the bridge, triggering a mac address of the bridge change each time (I
> did not notice that).

I think this is what you need to investigate rather than making
changes to the bridge layer.
