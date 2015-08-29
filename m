From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] tunnels: fix incorrect IPv4/v6 headers
 interpretation
Date: Sat, 29 Aug 2015 13:08:10 -0700 (PDT)
Message-ID: <20150829.130810.1498520909891590692.davem@davemloft.net>
References: <cover.1440787600.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, pshelar@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbbH2UIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:08:11 -0400
In-Reply-To: <cover.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 28 Aug 2015 20:48:18 +0200

> With tunneling, it is currently possible to get an IPv6 header and interpret
> it as an IPv4 header, or to interpret an IPv6 address as an IPv4 address
> (and vice versa). This leads to things like sending packets to incorrect
> address, IPv6 flow label being interpreted as IP packet length, etc.
> 
> Fix several places where this can happen.
> 
> Most of this is net-next only. The third patch affects net, too, but it
> doesn't seem there's anything in user space that sets the attribute at all
> currently, thus net-next is fine.
> 
> Changelog:
> v2: fixed geneve after incorrect rebase on top of Pravin's patches

Series applied, thanks Jiri.
