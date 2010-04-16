From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] packet : remove init_net restriction
Date: Fri, 16 Apr 2010 15:41:26 -0700 (PDT)
Message-ID: <20100416.154126.152614206.davem@davemloft.net>
References: <1271322674-21726-1-git-send-email-daniel.lezcano@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36976
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932716Ab0DPWlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 18:41:22 -0400
In-Reply-To: <1271322674-21726-1-git-send-email-daniel.lezcano@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <daniel.lezcano@free.fr>
Date: Thu, 15 Apr 2010 11:11:14 +0200

> The af_packet protocol is used by Perl to do ioctls as reported by
> Stephane Riviere:
> 
> "Net::RawIP relies on SIOCGIFADDR et SIOCGIFHWADDR to get the IP and MAC
> addresses of the network interface."
> 
> But in a new network namespace these ioctl fail because it is disabled for
> a namespace different from the init_net_ns.
> 
> These two lines should not be there as af_inet and af_packet are
> namespace aware since a long time now. I suppose we forget to remove these
> lines because we sent the af_packet first, before af_inet was supported.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Reported-by: Stephane Riviere <stephane.riviere@regis-dgac.net>

Applied, thanks!
