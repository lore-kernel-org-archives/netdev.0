From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] TCP: Use 32768-65535 outgoing port range by default
Date: Tue, 03 Apr 2012 00:50:27 -0400 (EDT)
Message-ID: <20120403.005027.988304181797945160.davem@davemloft.net>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
	<20120403095018.rm7gil9xz0gsgccs@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: fernando@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751Ab2DCEum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 00:50:42 -0400
In-Reply-To: <20120403095018.rm7gil9xz0gsgccs@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fernando@intellilink.co.jp
Date: Tue,  3 Apr 2012 09:50:18 +0900

> There was a time when the ip masquerading code reserved the
> 61000-65095 port range, which is the reason why the current default
> upper limit in ip_local_port_range is 61000. However, the current
> iptables-based masquerading and SNAT implementation does not have
> that restriction; ipchains and the compatibilty mode that used the
> range over 61000 exclusively is lone gone.

I don't think so, anyone out there using "--to-port 61000-65095"
or similar in their firewall setup will suddenly break with
your change.

I'm not applying this patch.
