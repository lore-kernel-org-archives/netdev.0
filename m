From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] vxlan: support both IPv4 and IPv6 sockets
Date: Sat, 26 Sep 2015 22:41:10 -0700 (PDT)
Message-ID: <20150926.224110.1190457686665465368.davem@davemloft.net>
References: <cover.1443094736.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbI0FlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 01:41:11 -0400
In-Reply-To: <cover.1443094736.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 24 Sep 2015 13:50:00 +0200

> Note: this needs net merged into net-next in order to apply.
> 
> It's currently not easy enough to work with metadata based vxlan tunnels. In
> particular, it's necessary to create separate network interfaces for IPv4
> and IPv6 tunneling. Assigning an IPv6 address to an IPv4 interface is
> allowed yet won't do what's expected. With route based tunneling, one has to
> pay attention to use the vxlan interface opened with the correct family.
> Other users of this (openvswitch) would need to always create two vxlan
> interfaces.
> 
> Furthermore, there's no sane API for creating an IPv6 vxlan metadata based
> interface.
> 
> This patchset simplifies this by opening both IPv4 and IPv6 socket if the
> vxlan interface has the metadata flag (IFLA_VXLAN_COLLECT_METADATA) set.
> Assignment of addresses etc. works as expected after this.

Series applied, thanks Jiri.
