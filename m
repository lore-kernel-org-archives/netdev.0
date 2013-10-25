From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] packet: Deliver VLAN TPID to userspace
Date: Fri, 25 Oct 2013 18:59:20 -0400 (EDT)
Message-ID: <20131025.185920.1893524127229371162.davem@davemloft.net>
References: <87r4bdk8c3.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	bhutchings@solarflare.com
To: atzm@stratosphere.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962Ab3JYW7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 18:59:24 -0400
In-Reply-To: <87r4bdk8c3.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atzm Watanabe <atzm@stratosphere.co.jp>
Date: Tue, 22 Oct 2013 17:39:40 +0900

>  struct tpacket_hdr_variant1 {
>  	__u32	tp_rxhash;
>  	__u32	tp_vlan_tci;
> +	__u32	tp_vlan_tpid;
>  };
>  

You cannot do this, the header length is not variable.

This patch has been submitted several times, each of which you
have been shown ways in which your changes break userspace in
one way or another.
